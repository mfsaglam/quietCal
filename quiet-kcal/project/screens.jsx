// screens.jsx — wireframe screens for Quiet Kcal
// Uses primitives from wireframes.jsx (SkBox, SkCircle, Hand, etc.)

// ─── Shared sketchy phone shell ───
function Phone({ children, width = 360, height = 740, label }) {
  return (
    <div style={{ position: 'relative' }}>
      {label && (
        <div style={{
          position: 'absolute', bottom: '100%', left: 0, paddingBottom: 10,
          fontFamily: HAND, fontSize: 18, color: INK, fontWeight: 500,
        }}>{label}</div>
      )}
      <div style={{
        width, height, borderRadius: 44, background: PAPER,
        position: 'relative', overflow: 'hidden',
        boxShadow: '0 1px 0 rgba(0,0,0,0.9), 0 2px 0 rgba(0,0,0,0.9)',
        border: '2px solid #1a1a1a',
      }}>
        <SketchyStatusBar />
        <div style={{ position: 'absolute', top: 8, left: '50%', transform: 'translateX(-50%)', width: 90, height: 24, borderRadius: 14, background: INK }} />
        <div style={{ height: 'calc(100% - 40px)', overflow: 'hidden' }}>
          {children}
        </div>
        <SketchyHomeBar />
      </div>
    </div>
  );
}

// ─── Header block: big title + date ───
function ScreenHeader({ title, subtitle, right }) {
  return (
    <div style={{ padding: '12px 24px 8px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
      <div>
        <Hand size={30} weight={600}>{title}</Hand>
        {subtitle && <div style={{ fontFamily: HAND, fontSize: 14, color: MUTED, marginTop: 2 }}>{subtitle}</div>}
      </div>
      {right}
    </div>
  );
}

// ─── Tab bar (bottom) ───
function TabBar({ active = 'home' }) {
  const tabs = [
    { id: 'home', label: 'Today' },
    { id: 'hist', label: 'History' },
    { id: 'set', label: 'Settings' },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 20, left: 16, right: 16, height: 46,
      display: 'flex', alignItems: 'center', justifyContent: 'space-around',
    }}>
      <SkBox w="100%" h={46} r={23} sw={1.3} fill={PAPER} seed={9}>
        <div style={{ display: 'flex', width: '100%', height: '100%', alignItems: 'center' }}>
          {tabs.map(t => (
            <div key={t.id} style={{
              flex: 1, textAlign: 'center',
              fontFamily: HAND, fontSize: 15,
              color: active === t.id ? INK : MUTED,
              fontWeight: active === t.id ? 600 : 400,
              textDecoration: active === t.id ? 'underline' : 'none',
              textDecorationThickness: 1.5,
              textUnderlineOffset: 4,
            }}>{t.label}</div>
          ))}
        </div>
      </SkBox>
    </div>
  );
}

// ─── Meal row ───
function MealRow({ name, grams, kcal, time }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '10px 0', borderBottom: `1px dashed ${FADE}`, gap: 12,
    }}>
      <div style={{ minWidth: 0, flex: 1 }}>
        <div style={{
          fontFamily: HAND, fontSize: 17, color: INK,
          whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
        }}>{name}</div>
        <div style={{ fontFamily: MONO, fontSize: 10, color: MUTED, marginTop: 2 }}>
          {grams}g · {time}
        </div>
      </div>
      <div style={{ fontFamily: HAND, fontSize: 18, color: INK, fontWeight: 500, flexShrink: 0 }}>{kcal}</div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// HOME — VARIATION A: Ring
// ═══════════════════════════════════════════════════════════════
function HomeRing() {
  return (
    <Phone label="A — Ring (classic Activity feel)">
      <ScreenHeader title="Today" subtitle="Thu · Apr 18" />
      <div style={{ padding: '8px 24px 0', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <div style={{ position: 'relative', width: 200, height: 200 }}>
          <SkCircle size={200} stroke={FADE} sw={14} progress={0.62} progressColor={INK} />
          <div style={{
            position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'center',
          }}>
            <Hand size={44} weight={600}>1,240</Hand>
            <div style={{ fontFamily: MONO, fontSize: 10, color: MUTED, letterSpacing: 1 }}>
              OF 2,000 KCAL
            </div>
            <div style={{ fontFamily: HAND, fontSize: 14, color: MUTED, marginTop: 4 }}>760 left</div>
          </div>
        </div>
      </div>
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{ fontFamily: MONO, fontSize: 10, color: MUTED, letterSpacing: 1, marginBottom: 6 }}>
          MEALS · 3
        </div>
        <MealRow name="Oatmeal + berries" grams="220" kcal="310" time="08:15" />
        <MealRow name="Chicken salad" grams="340" kcal="520" time="12:45" />
        <MealRow name="Apple" grams="180" kcal="95" time="15:20" />
      </div>
      <SkFAB bottom={96} right={24} />
      <TabBar active="home" />
    </Phone>
  );
}

// ═══════════════════════════════════════════════════════════════
// HOME — VARIATION B: Big Number
// ═══════════════════════════════════════════════════════════════
function HomeBigNumber() {
  return (
    <Phone label="B — Big number (typographic)">
      <ScreenHeader title="Today" subtitle="Thu · Apr 18" />
      <div style={{ padding: '24px 24px 0', textAlign: 'left' }}>
        <div style={{ fontFamily: MONO, fontSize: 10, color: MUTED, letterSpacing: 1 }}>EATEN</div>
        <div style={{ fontFamily: HAND, fontSize: 96, fontWeight: 600, color: INK, lineHeight: 1, marginTop: 4 }}>
          1,240
        </div>
        <div style={{ display: 'flex', gap: 24, marginTop: 14 }}>
          <div>
            <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1 }}>TARGET</div>
            <Hand size={22} weight={500}>2,000</Hand>
          </div>
          <div>
            <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1 }}>LEFT</div>
            <Hand size={22} weight={500}>760</Hand>
          </div>
        </div>
        {/* thin bar */}
        <div style={{ marginTop: 16, position: 'relative', height: 10 }}>
          <SkBox w="100%" h={10} r={5} sw={1.2} seed={3} />
          <div style={{
            position: 'absolute', top: 2, left: 2, height: 6, width: '60%',
            background: INK, borderRadius: 4,
          }} />
        </div>
      </div>
      <div style={{ padding: '24px 24px 0' }}>
        <div style={{ fontFamily: MONO, fontSize: 10, color: MUTED, letterSpacing: 1, marginBottom: 6 }}>
          MEALS
        </div>
        <MealRow name="Oatmeal + berries" grams="220" kcal="310" time="08:15" />
        <MealRow name="Chicken salad" grams="340" kcal="520" time="12:45" />
        <MealRow name="Apple" grams="180" kcal="95" time="15:20" />
        <MealRow name="Coffee + milk" grams="240" kcal="80" time="16:10" />
      </div>
      <SkFAB bottom={96} right={24} />
      <TabBar active="home" />
    </Phone>
  );
}

// ═══════════════════════════════════════════════════════════════
// HOME — VARIATION C: Countdown (remaining)
// ═══════════════════════════════════════════════════════════════
function HomeCountdown() {
  return (
    <Phone label="C — Countdown (remaining)">
      <ScreenHeader title="Today" subtitle="Thu · Apr 18" />
      <div style={{ padding: '40px 24px 0', textAlign: 'center' }}>
        <div style={{ fontFamily: HAND, fontSize: 16, color: MUTED }}>you have</div>
        <div style={{ fontFamily: HAND, fontSize: 108, fontWeight: 600, color: INK, lineHeight: 1, margin: '4px 0' }}>
          760
        </div>
        <div style={{ fontFamily: HAND, fontSize: 16, color: MUTED }}>kcal left today</div>
        {/* dots representing target slots */}
        <div style={{ display: 'flex', gap: 4, justifyContent: 'center', marginTop: 28, flexWrap: 'wrap', padding: '0 20px' }}>
          {Array.from({ length: 20 }).map((_, i) => (
            <div key={i} style={{
              width: 10, height: 10, borderRadius: 5,
              background: i < 12 ? INK : 'transparent',
              border: `1.2px solid ${i < 12 ? INK : MUTED}`,
            }} />
          ))}
        </div>
        <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1, marginTop: 10 }}>
          1,240 / 2,000 KCAL · EACH DOT = 100
        </div>
      </div>
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{ fontFamily: MONO, fontSize: 10, color: MUTED, letterSpacing: 1, marginBottom: 6 }}>
          3 MEALS TODAY
        </div>
        <MealRow name="Oatmeal + berries" grams="220" kcal="310" time="08:15" />
        <MealRow name="Chicken salad" grams="340" kcal="520" time="12:45" />
      </div>
      <SkFAB bottom={96} right={24} />
      <TabBar active="home" />
    </Phone>
  );
}

// ═══════════════════════════════════════════════════════════════
// HOME — VARIATION D: Over target (warning state)
// ═══════════════════════════════════════════════════════════════
function HomeOverTarget() {
  return (
    <Phone label="D — Over target (warning state)">
      <ScreenHeader title="Today" subtitle="Thu · Apr 18" />
      <div style={{ padding: '24px 24px 0', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <div style={{ position: 'relative', width: 200, height: 200 }}>
          <SkCircle size={200} stroke={FADE} sw={14} progress={1} progressColor={WARN} />
          <div style={{
            position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'center',
          }}>
            <Hand size={44} weight={600} color={WARN}>2,180</Hand>
            <div style={{ fontFamily: MONO, fontSize: 10, color: MUTED, letterSpacing: 1 }}>
              OF 2,000 KCAL
            </div>
            <Hand size={14} color={WARN} style={{ marginTop: 4 }}>+180 over</Hand>
          </div>
        </div>
      </div>
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{ fontFamily: MONO, fontSize: 10, color: WARN, letterSpacing: 1, marginBottom: 6 }}>
          OVER TARGET
        </div>
        <MealRow name="Oatmeal + berries" grams="220" kcal="310" time="08:15" />
        <MealRow name="Pasta carbonara" grams="420" kcal="890" time="12:45" />
        <MealRow name="Chocolate bar" grams="100" kcal="540" time="15:20" />
        <MealRow name="Rice + beans" grams="300" kcal="440" time="19:10" />
      </div>
      <SkFAB bottom={96} right={24} />
      <TabBar active="home" />
    </Phone>
  );
}

// ═══════════════════════════════════════════════════════════════
// ADD MEAL — sheet
// ═══════════════════════════════════════════════════════════════
function AddMealSheet() {
  return (
    <Phone label="Add meal — sheet">
      {/* dimmed background showing home peek */}
      <div style={{ padding: '12px 24px 8px', opacity: 0.35 }}>
        <Hand size={30} weight={600}>Today</Hand>
      </div>
      <div style={{ padding: '0 24px', opacity: 0.25, textAlign: 'center', marginTop: 20 }}>
        <Hand size={60} weight={600}>1,240</Hand>
      </div>
      {/* sheet */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, height: '72%',
        background: PAPER, borderTopLeftRadius: 28, borderTopRightRadius: 28,
        borderTop: `1.5px solid ${INK}`, borderLeft: `1.5px solid ${INK}`,
        borderRight: `1.5px solid ${INK}`,
        padding: '10px 24px 20px',
      }}>
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 12 }}>
          <div style={{ width: 40, height: 4, borderRadius: 2, background: MUTED }} />
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
          <Hand size={14} color={MUTED}>Cancel</Hand>
          <Hand size={22} weight={600}>New Meal</Hand>
          <Hand size={14} weight={600}>Save</Hand>
        </div>
        {/* name field */}
        <div style={{ marginBottom: 14 }}>
          <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1, marginBottom: 4 }}>NAME</div>
          <SkBox h={44} r={10} sw={1.2} seed={5}>
            <div style={{ padding: '10px 14px', fontFamily: HAND, fontSize: 17, color: INK }}>
              Chicken salad<span style={{ borderLeft: `1.5px solid ${INK}`, marginLeft: 2, animation: 'none' }}>&nbsp;</span>
            </div>
          </SkBox>
        </div>
        {/* grams + kcal row */}
        <div style={{ display: 'flex', gap: 12, marginBottom: 20 }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1, marginBottom: 4 }}>GRAMS</div>
            <SkBox h={44} r={10} sw={1.2} seed={6}>
              <div style={{ padding: '10px 14px', fontFamily: HAND, fontSize: 17, color: INK }}>340</div>
            </SkBox>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1, marginBottom: 4 }}>KCAL</div>
            <SkBox h={44} r={10} sw={1.2} seed={7}>
              <div style={{ padding: '10px 14px', fontFamily: HAND, fontSize: 17, color: INK }}>520</div>
            </SkBox>
          </div>
        </div>
        {/* unit toggle */}
        <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1, marginBottom: 6 }}>UNIT</div>
        <div style={{ display: 'flex', gap: 0, marginBottom: 18 }}>
          {['g', 'oz', 'lb'].map((u, i) => (
            <div key={u} style={{
              flex: 1, padding: '8px 0', textAlign: 'center',
              fontFamily: HAND, fontSize: 15,
              background: i === 0 ? INK : 'transparent',
              color: i === 0 ? PAPER : INK,
              border: `1.3px solid ${INK}`,
              borderRight: i < 2 ? 'none' : `1.3px solid ${INK}`,
              borderTopLeftRadius: i === 0 ? 8 : 0,
              borderBottomLeftRadius: i === 0 ? 8 : 0,
              borderTopRightRadius: i === 2 ? 8 : 0,
              borderBottomRightRadius: i === 2 ? 8 : 0,
            }}>{u}</div>
          ))}
        </div>
        {/* numeric keypad hint */}
        <SkPlaceholder w="100%" h={160} label="numeric keypad" />
      </div>
    </Phone>
  );
}

// ═══════════════════════════════════════════════════════════════
// HISTORY — list of days w/ mini bar
// ═══════════════════════════════════════════════════════════════
function HistoryView() {
  const days = [
    { d: 'Wed', date: 'Apr 17', kcal: 1890, pct: 0.94 },
    { d: 'Tue', date: 'Apr 16', kcal: 2150, pct: 1.07, over: true },
    { d: 'Mon', date: 'Apr 15', kcal: 1720, pct: 0.86 },
    { d: 'Sun', date: 'Apr 14', kcal: 2040, pct: 1.02, over: true },
    { d: 'Sat', date: 'Apr 13', kcal: 1600, pct: 0.8 },
    { d: 'Fri', date: 'Apr 12', kcal: 1950, pct: 0.97 },
    { d: 'Thu', date: 'Apr 11', kcal: 1810, pct: 0.9 },
  ];
  return (
    <Phone label="History">
      <ScreenHeader title="History" subtitle="last 7 days · avg 1,880" />
      {/* weekly bar chart */}
      <div style={{ padding: '12px 24px 0' }}>
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 10, height: 100, paddingBottom: 6, borderBottom: `1px dashed ${FADE}` }}>
          {[0.9, 0.97, 0.8, 1.02, 0.86, 1.07, 0.94].map((v, i) => (
            <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
              <div style={{
                width: '100%', height: Math.min(90, v * 70),
                background: v > 1 ? WARN : INK,
                borderRadius: 2,
              }} />
              <div style={{ fontFamily: MONO, fontSize: 8, color: MUTED }}>{['T','F','S','S','M','T','W'][i]}</div>
            </div>
          ))}
        </div>
      </div>
      <div style={{ padding: '16px 24px 0' }}>
        <div style={{ fontFamily: MONO, fontSize: 10, color: MUTED, letterSpacing: 1, marginBottom: 6 }}>
          DAYS
        </div>
        {days.map((day, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            padding: '10px 0', borderBottom: `1px dashed ${FADE}`,
          }}>
            <div>
              <div style={{ fontFamily: HAND, fontSize: 17, color: INK }}>{day.d} <span style={{ color: MUTED, fontSize: 14 }}>{day.date}</span></div>
              <div style={{ fontFamily: MONO, fontSize: 9, color: day.over ? WARN : MUTED, marginTop: 2 }}>
                {Math.round(day.pct * 100)}% of target
              </div>
            </div>
            <div style={{ fontFamily: HAND, fontSize: 18, color: day.over ? WARN : INK, fontWeight: 500 }}>
              {day.kcal}
            </div>
          </div>
        ))}
      </div>
      <TabBar active="hist" />
    </Phone>
  );
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════
function SettingsView() {
  return (
    <Phone label="Settings">
      <ScreenHeader title="Settings" />
      <div style={{ padding: '12px 16px 0' }}>
        {/* Target section */}
        <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1, padding: '0 8px 6px' }}>
          DAILY TARGET
        </div>
        <SkBox w="100%" r={14} sw={1.3} seed={10} fill={PAPER}>
          <div style={{ padding: '4px 14px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0', borderBottom: `1px dashed ${FADE}` }}>
              <Hand size={16}>Calorie target</Hand>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <Hand size={16} color={MUTED}>2,000 kcal</Hand>
                <span style={{ color: MUTED, fontSize: 14 }}>›</span>
              </div>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0' }}>
              <Hand size={16}>Weight unit</Hand>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <Hand size={16} color={MUTED}>grams</Hand>
                <span style={{ color: MUTED, fontSize: 14 }}>›</span>
              </div>
            </div>
          </div>
        </SkBox>

        <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1, padding: '18px 8px 6px' }}>
          APPEARANCE
        </div>
        <SkBox w="100%" r={14} sw={1.3} seed={11} fill={PAPER}>
          <div style={{ padding: '4px 14px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0', borderBottom: `1px dashed ${FADE}` }}>
              <Hand size={16}>Theme</Hand>
              <Hand size={16} color={MUTED}>system ›</Hand>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0' }}>
              <Hand size={16}>Progress style</Hand>
              <Hand size={16} color={MUTED}>ring ›</Hand>
            </div>
          </div>
        </SkBox>

        <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1, padding: '18px 8px 6px' }}>
          DATA
        </div>
        <SkBox w="100%" r={14} sw={1.3} seed={12} fill={PAPER}>
          <div style={{ padding: '4px 14px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0', borderBottom: `1px dashed ${FADE}` }}>
              <Hand size={16}>Export CSV</Hand>
              <span style={{ color: MUTED, fontSize: 14 }}>›</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0' }}>
              <Hand size={16} color={WARN}>Clear all data</Hand>
            </div>
          </div>
        </SkBox>
      </div>
      <TabBar active="set" />
    </Phone>
  );
}

// ═══════════════════════════════════════════════════════════════
// EDIT TARGET — push screen
// ═══════════════════════════════════════════════════════════════
function EditTarget() {
  return (
    <Phone label="Edit target">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 24px' }}>
        <Hand size={14} color={MUTED}>‹ Settings</Hand>
        <Hand size={14} weight={600}>Done</Hand>
      </div>
      <div style={{ padding: '20px 24px 0' }}>
        <Hand size={26} weight={600}>Daily target</Hand>
        <div style={{ fontFamily: HAND, fontSize: 14, color: MUTED, marginTop: 4 }}>
          How many kcal per day?
        </div>
      </div>
      <div style={{ padding: '40px 24px 0', textAlign: 'center' }}>
        <Hand size={80} weight={600}>2,000</Hand>
        <div style={{ fontFamily: MONO, fontSize: 10, color: MUTED, letterSpacing: 1, marginTop: 2 }}>KCAL</div>
      </div>
      {/* slider */}
      <div style={{ padding: '36px 24px 0', position: 'relative', height: 40 }}>
        <SkBox h={4} r={2} sw={1.2} seed={13} style={{ marginTop: 8 }} />
        <div style={{
          position: 'absolute', top: 0, left: '40%',
          width: 24, height: 24, borderRadius: 12,
          background: PAPER, border: `1.5px solid ${INK}`,
          boxShadow: '0 1px 2px rgba(0,0,0,0.1)',
        }} />
        <div style={{ display: 'flex', justifyContent: 'space-between', fontFamily: MONO, fontSize: 9, color: MUTED, marginTop: 12 }}>
          <span>1,200</span>
          <span>3,500</span>
        </div>
      </div>
      {/* presets */}
      <div style={{ padding: '36px 24px 0' }}>
        <div style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 1, marginBottom: 8 }}>
          QUICK PICK
        </div>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {['1,500', '1,800', '2,000', '2,200', '2,500'].map((p, i) => (
            <div key={p} style={{
              padding: '6px 14px', borderRadius: 16,
              border: `1.2px solid ${i === 2 ? INK : MUTED}`,
              background: i === 2 ? INK : 'transparent',
              color: i === 2 ? PAPER : INK,
              fontFamily: HAND, fontSize: 14,
            }}>{p}</div>
          ))}
        </div>
      </div>
    </Phone>
  );
}

Object.assign(window, {
  Phone, ScreenHeader, TabBar, MealRow,
  HomeRing, HomeBigNumber, HomeCountdown, HomeOverTarget,
  AddMealSheet, HistoryView, SettingsView, EditTarget,
});
