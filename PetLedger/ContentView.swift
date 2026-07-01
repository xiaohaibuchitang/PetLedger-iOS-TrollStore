import SwiftUI

struct LedgerEntry: Identifiable {
    let id = UUID()
    var icon: String
    var title: String
    var category: String
    var amount: Double
    var tint: Color
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showAddEntry = false
    @State private var petMessage = "今天也一起慢慢存钱。"
    @State private var petEnergy = 0.74
    @State private var entries: [LedgerEntry] = [
        LedgerEntry(icon: "cup.and.saucer.fill", title: "早餐咖啡", category: "餐饮", amount: 18, tint: .brown),
        LedgerEntry(icon: "tram.fill", title: "地铁通勤", category: "交通", amount: 6, tint: .blue),
        LedgerEntry(icon: "book.fill", title: "学习资料", category: "学习", amount: 44, tint: .indigo)
    ]

    private var todaySpend: Double {
        entries.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(
                    entries: entries,
                    todaySpend: todaySpend,
                    petEnergy: petEnergy,
                    petMessage: petMessage,
                    showAddEntry: $showAddEntry,
                    selectedTab: $selectedTab
                )
            }
            .tabItem { Label("记账", systemImage: "list.bullet.rectangle.portrait.fill") }
            .tag(0)

            PetRoomView(message: $petMessage, energy: $petEnergy)
                .tabItem { Label("精灵", systemImage: "sparkles") }
                .tag(1)

            InsightsView(todaySpend: todaySpend)
                .tabItem { Label("洞察", systemImage: "chart.pie.fill") }
                .tag(2)
        }
        .tint(.primary)
        .sheet(isPresented: $showAddEntry) {
            AddEntrySheet(entries: $entries, petMessage: $petMessage)
                .presentationDetents([.medium])
        }
    }
}

struct DashboardView: View {
    var entries: [LedgerEntry]
    var todaySpend: Double
    var petEnergy: Double
    var petMessage: String
    @Binding var showAddEntry: Bool
    @Binding var selectedTab: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                balanceCard
                petPreview
                recentList
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(AppColors.canvas.ignoresSafeArea())
        .navigationTitle("今天")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddEntry = true
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .frame(width: 34, height: 34)
                        .background(.white, in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("今日支出")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("¥\(todaySpend, specifier: "%.0f")")
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                    Text("预算剩余 ¥132")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColors.green)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(AppColors.line, lineWidth: 9)
                    Circle()
                        .trim(from: 0, to: 0.64)
                        .stroke(AppColors.green, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("64%")
                        .font(.headline)
                }
                .frame(width: 86, height: 86)
            }

            HStack(spacing: 10) {
                StatPill(title: "本周", value: "¥426", icon: "calendar")
                StatPill(title: "存下", value: "¥88", icon: "leaf.fill")
            }
        }
        .padding(22)
        .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 18, y: 8)
    }

    private var petPreview: some View {
        Button {
            selectedTab = 1
        } label: {
            HStack(spacing: 16) {
                MiniPet(energy: petEnergy)
                    .frame(width: 78, height: 78)

                VStack(alignment: .leading, spacing: 7) {
                    Text("小精灵在等你")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(petMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    ProgressView(value: petEnergy)
                        .tint(AppColors.green)
                }

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var recentList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近记录")
                    .font(.headline)
                Spacer()
                Text("共 \(entries.count) 笔")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            ForEach(entries) { entry in
                HStack(spacing: 13) {
                    Image(systemName: entry.icon)
                        .font(.headline)
                        .foregroundStyle(entry.tint)
                        .frame(width: 42, height: 42)
                        .background(entry.tint.opacity(0.12), in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                            .font(.subheadline.weight(.semibold))
                        Text(entry.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("-¥\(entry.amount, specifier: "%.0f")")
                        .font(.subheadline.weight(.semibold))
                }
                .padding(14)
                .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }
}

struct PetRoomView: View {
    @Binding var message: String
    @Binding var energy: Double
    @State private var selectedItem = "窝"
    @State private var sparkle = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    roomScene
                    interactionPanel
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(AppColors.canvas.ignoresSafeArea())
            .navigationTitle("精灵房间")
        }
    }

    private var roomScene: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xF7FBF8), Color(hex: 0xEAF3EE)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: proxy.size.width * 0.9, height: 150)
                    .blur(radius: 24)
                    .offset(y: 40)

                RoomBed()
                    .frame(width: 118, height: 82)
                    .position(x: 86, y: 276)
                    .onTapGesture { interact("窝", text: "窝被整理好啦，小精灵睡得更安心。", delta: 0.08) }

                RoomPlant()
                    .frame(width: 78, height: 128)
                    .position(x: proxy.size.width - 68, y: 218)
                    .onTapGesture { interact("绿植", text: "你摸了摸叶子，房间空气变清爽了。", delta: 0.05) }

                CoinJar()
                    .frame(width: 74, height: 90)
                    .position(x: proxy.size.width - 88, y: 306)
                    .onTapGesture { interact("存钱罐", text: "叮咚，今天的小目标又亮了一点。", delta: 0.06) }

                TimelineView(.animation) { timeline in
                    let seconds = timeline.date.timeIntervalSinceReferenceDate
                    let walk = CGFloat(sin(seconds * 0.82)) * min(proxy.size.width * 0.22, 82)
                    let bob = CGFloat(cos(seconds * 2.2)) * 5

                    PetSprite(sparkle: sparkle)
                        .frame(width: 116, height: 126)
                        .position(x: proxy.size.width * 0.5 + walk, y: 266 + bob)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedItem)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(16)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(height: 380)
    }

    private var interactionPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("互动")
                .font(.headline)

            HStack(spacing: 10) {
                PetActionButton(title: "喂食", icon: "takeoutbag.and.cup.and.straw.fill") {
                    interact("小点心", text: "小精灵吃到了喜欢的小点心。", delta: 0.12)
                }
                PetActionButton(title: "摸摸", icon: "hand.tap.fill") {
                    interact("陪伴", text: "它靠近你蹭了蹭，心情变好了。", delta: 0.1)
                }
                PetActionButton(title: "散步", icon: "figure.walk") {
                    interact("散步", text: "它绕着房间跑了一圈，像一颗小星星。", delta: 0.07)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("亲密度")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(Int(energy * 100))%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.green)
                }
                ProgressView(value: energy)
                    .tint(AppColors.green)
            }
        }
        .padding(18)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func interact(_ item: String, text: String, delta: Double) {
        selectedItem = item
        message = text
        energy = min(1, energy + delta)
        withAnimation(.spring(response: 0.28, dampingFraction: 0.62)) {
            sparkle.toggle()
        }
    }
}

struct InsightsView: View {
    var todaySpend: Double

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("你的消费节奏很稳定，今天最大支出来自学习。")
                        .font(.title3.weight(.semibold))
                        .padding(22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                    VStack(spacing: 12) {
                        InsightRow(title: "餐饮", value: 0.26, amount: "¥18", tint: .brown)
                        InsightRow(title: "交通", value: 0.09, amount: "¥6", tint: .blue)
                        InsightRow(title: "学习", value: 0.65, amount: "¥44", tint: .indigo)
                    }
                    .padding(18)
                    .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    Text("今日合计 ¥\(todaySpend, specifier: "%.0f")")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(18)
            }
            .background(AppColors.canvas.ignoresSafeArea())
            .navigationTitle("洞察")
        }
    }
}

struct AddEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entries: [LedgerEntry]
    @Binding var petMessage: String
    @State private var title = ""
    @State private var amount = ""
    @State private var category = "日常"

    var body: some View {
        NavigationStack {
            Form {
                Section("记录") {
                    TextField("名称", text: $title)
                    TextField("金额", text: $amount)
                        .keyboardType(.decimalPad)
                    Picker("分类", selection: $category) {
                        Text("日常").tag("日常")
                        Text("餐饮").tag("餐饮")
                        Text("交通").tag("交通")
                        Text("学习").tag("学习")
                        Text("恋爱").tag("恋爱")
                    }
                }
            }
            .navigationTitle("新增支出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        addEntry()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func addEntry() {
        let value = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard value > 0 else { return }
        let itemTitle = title.isEmpty ? "新的支出" : title
        entries.insert(
            LedgerEntry(icon: icon(for: category), title: itemTitle, category: category, amount: value, tint: tint(for: category)),
            at: 0
        )
        petMessage = "记下这一笔后，预算变得更清楚了。"
        dismiss()
    }

    private func icon(for category: String) -> String {
        switch category {
        case "餐饮": return "fork.knife"
        case "交通": return "tram.fill"
        case "学习": return "book.fill"
        case "恋爱": return "heart.fill"
        default: return "bag.fill"
        }
    }

    private func tint(for category: String) -> Color {
        switch category {
        case "餐饮": return .brown
        case "交通": return .blue
        case "学习": return .indigo
        case "恋爱": return .pink
        default: return .orange
        }
    }
}

struct StatPill: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.footnote.weight(.semibold))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct PetActionButton: View {
    var title: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(AppColors.canvas, in: Circle())
                Text(title)
                    .font(.footnote.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(AppColors.softGreen, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct InsightRow: View {
    var title: String
    var value: Double
    var amount: String
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(amount)
                    .font(.subheadline.weight(.semibold))
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.canvas)
                    Capsule()
                        .fill(tint.opacity(0.7))
                        .frame(width: proxy.size.width * value)
                }
            }
            .frame(height: 9)
        }
    }
}

struct MiniPet: View {
    var energy: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.softGreen)
            PetSprite(sparkle: energy > 0.8)
                .scaleEffect(0.58)
        }
    }
}

struct PetSprite: View {
    var sparkle: Bool

    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xFFF8E8), Color(hex: 0xF5C9B5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 86, height: 96)
                .shadow(color: Color(hex: 0xB88A75).opacity(0.18), radius: 14, y: 10)

            HStack(spacing: 46) {
                Circle().fill(Color(hex: 0xFFF8E8)).frame(width: 28, height: 34)
                Circle().fill(Color(hex: 0xFFF8E8)).frame(width: 28, height: 34)
            }
            .offset(y: -48)

            HStack(spacing: 22) {
                Circle().fill(Color(hex: 0x3C302C)).frame(width: 8, height: 10)
                Circle().fill(Color(hex: 0x3C302C)).frame(width: 8, height: 10)
            }
            .offset(y: -10)

            Capsule()
                .fill(Color(hex: 0xDB8F81))
                .frame(width: 20, height: 7)
                .offset(y: 12)

            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 18, height: 18)
                .offset(x: -24, y: -26)

            if sparkle {
                Image(systemName: "sparkle")
                    .font(.title2)
                    .foregroundStyle(AppColors.green)
                    .offset(x: 48, y: -46)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct RoomBed: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0xD8E9DF))
                .frame(height: 48)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.9))
                .frame(width: 76, height: 34)
                .offset(y: -18)
            Capsule()
                .fill(Color(hex: 0xA9D0BE))
                .frame(width: 104, height: 18)
        }
    }
}

struct RoomPlant: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: 0xCFAE87))
                .frame(width: 44, height: 40)
            VStack(spacing: -6) {
                Leaf(angle: -28)
                Leaf(angle: 24)
                Leaf(angle: -12)
            }
            .offset(y: -28)
        }
    }
}

struct Leaf: View {
    var angle: Double

    var body: some View {
        Capsule()
            .fill(AppColors.green)
            .frame(width: 28, height: 48)
            .rotationEffect(.degrees(angle))
    }
}

struct CoinJar: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(hex: 0xB9D6CC), lineWidth: 2)
                )
            Capsule()
                .fill(Color(hex: 0xD9B66E))
                .frame(width: 42, height: 9)
                .offset(y: -25)
            Text("¥")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.green)
        }
    }
}

enum AppColors {
    static let canvas = Color(hex: 0xF4F5F2)
    static let line = Color(hex: 0xE1E5DF)
    static let green = Color(hex: 0x4F8E6A)
    static let softGreen = Color(hex: 0xEAF4ED)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

