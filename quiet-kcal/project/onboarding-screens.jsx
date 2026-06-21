// onboarding-screens.jsx — Quiet Kcal first-run flow (static screens)
// Reuses HF, SF, SFR, AnimatedRing, IOSGlassPill from the hi-fi set.

// ── Apple Intelligence sparkle ──
function OnbSparkle({ size = 14 }) {
  const id = React.useMemo(() => 'aigr-onb-' + Math.random().toString(36).slice(2, 7), []);
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <defs>
        <linearGradient id={id} x1="0" y1="0" x2="24" y2="24">
          <stop offset="0" stopColor="#AF52DE" />
          <stop offset="1" stopColor="#FF2D92" />
        </linearGradient>
      </defs>
      <path d="M12 2l2.2 5.8L20 10l-5.8 2.2L12 18l-2.2-5.8L4 10l5.8-2.2L12 2z" fill={`url(#${id})`} />
      <circle cx="19" cy="5" r="1.4" fill={`url(#${id})`} />
      <circle cx="5" cy="20" r="1.1" fill={`url(#${id})`} />
    </svg>
  );
}

// ── Shared building blocks ──
function OnbShell({ children, dark }) {
  const paper = dark ? HF.paperD : HF.paper;
  return (
    <div style={{ background: paper, height: '100%', display: 'flex', flexDirection: 'column' }}>
      {children}
    </div>
  );
}

function OnbTopBar({ dark, showSkip }) {
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  return (
    <div style={{
      paddingTop: 56, height: 56, boxSizing: 'content-box',
      display: 'flex', alignItems: 'center', justifyContent: 'flex-end',
      padding: '56px 22px 0',
    }}>
      {showSkip && (
        <span style={{ fontFamily: SF, fontSize: 16, fontWeight: 500, color: muted, letterSpacing: -0.2 }}>
          Skip
        </span>
      )}
    </div>
  );
}

function OnbDots({ n, active, dark }) {
  const ink = dark ? HF.inkD : HF.ink;
  const track = dark ? 'rgba(255,255,255,0.18)' : 'rgba(60,60,67,0.18)';
  return (
    <div style={{ display: 'flex', gap: 7, alignItems: 'center', justifyContent: 'center' }}>
      {Array.from({ length: n }).map((_, i) => (
        <div key={i} style={{
          width: i === active ? 22 : 7, height: 7, borderRadius: 4,
          background: i === active ? ink : track,
          transition: 'width 240ms ease',
        }} />
      ))}
    </div>
  );
}

function OnbFooter({ dark, label, n, active, secondary }) {
  const ink = dark ? HF.inkD : HF.ink;
  const paper = dark ? HF.paperD : HF.paper;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  return (
    <div style={{ padding: '0 20px 44px', display: 'flex', flexDirection: 'column', gap: 22 }}>
      <OnbDots n={n} active={active} dark={dark} />
      <div style={{
        height: 56, borderRadius: 18, background: ink,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: dark ? 'none' : '0 6px 18px rgba(26,26,26,0.18)',
      }}>
        <span style={{ fontFamily: SF, fontSize: 18, fontWeight: 600, color: paper, letterSpacing: -0.3 }}>
          {label}
        </span>
      </div>
      {secondary && (
        <div style={{ textAlign: 'center', marginTop: -6 }}>
          <span style={{ fontFamily: SF, fontSize: 15, fontWeight: 500, color: muted, letterSpacing: -0.2 }}>{secondary}</span>
        </div>
      )}
    </div>
  );
}

// ═══ 1 · WELCOME ═══
function OnbWelcome({ dark = false }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  return (
    <OnbShell dark={dark}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 36px' }}>
        {/* Ring mark */}
        <div style={{ position: 'relative', width: 132, height: 132, marginBottom: 40 }}>
          <AnimatedRing size={132} stroke={12} progress={0.72} color={dark ? HF.inkD : HF.ring} trackColor={dark ? 'rgba(255,255,255,0.08)' : HF.ringTrack} />
          <div style={{
            position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <div style={{
              fontFamily: SFR, fontSize: 40, fontWeight: 600, color: text,
              letterSpacing: -1, lineHeight: 1,
            }}>Q</div>
          </div>
        </div>

        <div style={{
          fontFamily: SF, fontSize: 13, fontWeight: 600, color: muted,
          letterSpacing: 1.5, textTransform: 'uppercase', marginBottom: 14,
        }}>Quiet Kcal</div>
        <h1 style={{
          fontFamily: SF, fontSize: 38, fontWeight: 700, color: text,
          letterSpacing: -0.8, lineHeight: 1.08, textAlign: 'center', margin: 0,
          textWrap: 'balance',
        }}>Calorie tracking,<br />quietly.</h1>
        <p style={{
          fontFamily: SF, fontSize: 17, color: muted, letterSpacing: -0.3,
          lineHeight: 1.5, textAlign: 'center', margin: '18px 0 0', maxWidth: 300,
          textWrap: 'pretty',
        }}>
          Log a meal, get an instant estimate, watch one ring. No macros, no streaks, no noise.
        </p>
      </div>

      <OnbFooter dark={dark} label="Get started" n={5} active={0} secondary="A few quick steps · under a minute" />
    </OnbShell>
  );
}

// ═══ 2 · SET DAILY TARGET ═══
function OnbTarget({ dark = false }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  const surface = dark ? HF.surfaceD : HF.surface;
  const fieldBg = dark ? 'rgba(118,118,128,0.24)' : 'rgba(118,118,128,0.08)';

  return (
    <OnbShell dark={dark}>
      <OnbTopBar dark={dark} showSkip />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: '4px 28px 0' }}>
          <h1 style={{ fontFamily: SF, fontSize: 30, fontWeight: 700, color: text, letterSpacing: -0.6, margin: 0, textWrap: 'balance' }}>
            Set your daily target
          </h1>
          <p style={{ fontFamily: SF, fontSize: 16, color: muted, letterSpacing: -0.3, lineHeight: 1.45, margin: '10px 0 0', textWrap: 'pretty' }}>
            Pick a number to aim for each day. You can change it anytime in Settings.
          </p>
        </div>

        {/* Big number */}
        <div style={{ padding: '28px 20px 10px', textAlign: 'center' }}>
          <div style={{
            fontFamily: SFR, fontSize: 88, fontWeight: 600, color: text,
            letterSpacing: -3, lineHeight: 1, fontVariantNumeric: 'tabular-nums',
          }}>2,000</div>
          <div style={{ fontFamily: SF, fontSize: 13, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500, marginTop: 8 }}>
            kcal per day
          </div>
        </div>

        {/* Slider */}
        <div style={{ padding: '12px 20px 0' }}>
          <div style={{ background: surface, borderRadius: 22, padding: '22px 20px' }}>
            <div style={{ position: 'relative', height: 28 }}>
              <div style={{ position: 'absolute', top: 12, left: 0, right: 0, height: 4, borderRadius: 2, background: fieldBg }} />
              <div style={{ position: 'absolute', top: 12, left: 0, width: '35%', height: 4, borderRadius: 2, background: text }} />
              <div style={{
                position: 'absolute', top: 0, left: 'calc(35% - 14px)', width: 28, height: 28, borderRadius: 14, background: '#fff',
                boxShadow: '0 3px 8px rgba(0,0,0,0.15), 0 0 0 0.5px rgba(0,0,0,0.04)',
              }} />
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontFamily: SF, fontSize: 12, color: muted, marginTop: 10, fontVariantNumeric: 'tabular-nums' }}>
              <span>1,200</span>
              <span>3,500</span>
            </div>
          </div>
        </div>

        {/* Presets */}
        <div style={{ padding: '18px 20px 0' }}>
          <div style={{ fontFamily: SF, fontSize: 13, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500, padding: '0 4px 8px' }}>Quick pick</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {[{ v: '1,500' }, { v: '1,800' }, { v: '2,000', active: true }, { v: '2,200' }, { v: '2,500' }, { v: '2,800' }].map((p) => (
              <div key={p.v} style={{
                padding: '10px 18px', borderRadius: 18,
                background: p.active ? text : surface,
                color: p.active ? (dark ? HF.paperD : HF.paper) : text,
                fontFamily: SF, fontSize: 15, fontWeight: 500, letterSpacing: -0.2, fontVariantNumeric: 'tabular-nums',
              }}>{p.v}</div>
            ))}
          </div>
        </div>
      </div>

      <OnbFooter dark={dark} label="Continue" n={5} active={1} />
    </OnbShell>
  );
}

// ═══ 3 · HOW ESTIMATES WORK ═══
function OnbEstimates({ dark = false }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  const surface = dark ? HF.surfaceD : HF.surface;
  const aiPurple = '#AF52DE';

  const steps = [
    { t: 'Type what you ate', d: 'A name and a rough amount — “chicken salad, 340g.”' },
    { t: 'Get an instant estimate', d: 'Apple Intelligence estimates the calories on device.' },
    { t: 'Adjust if needed', d: 'Every estimate stays editable. Tap to correct it.' },
  ];

  return (
    <OnbShell dark={dark}>
      <OnbTopBar dark={dark} showSkip />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: '4px 28px 0' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 12 }}>
            <OnbSparkle size={16} />
            <span style={{ fontFamily: SF, fontSize: 13, fontWeight: 600, color: aiPurple, letterSpacing: 0.5, textTransform: 'uppercase' }}>
              Apple Intelligence
            </span>
          </div>
          <h1 style={{ fontFamily: SF, fontSize: 30, fontWeight: 700, color: text, letterSpacing: -0.6, margin: 0, textWrap: 'balance' }}>
            How estimates work
          </h1>
          <p style={{ fontFamily: SF, fontSize: 16, color: muted, letterSpacing: -0.3, lineHeight: 1.45, margin: '10px 0 0', textWrap: 'pretty' }}>
            No databases to search or barcodes to scan. Just describe the meal.
          </p>
        </div>

        {/* Mock estimate card */}
        <div style={{ padding: '24px 20px 4px' }}>
          <div style={{ background: surface, borderRadius: 22, padding: 18 }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
              <div style={{ minWidth: 0 }}>
                <div style={{ fontFamily: SF, fontSize: 17, fontWeight: 500, color: text, letterSpacing: -0.4, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                  Chicken salad
                </div>
                <div style={{ fontFamily: SF, fontSize: 13, color: muted, letterSpacing: -0.08, marginTop: 2 }}>340 g</div>
              </div>
              <div style={{ textAlign: 'right', flexShrink: 0 }}>
                <div style={{ fontFamily: SFR, fontSize: 26, fontWeight: 600, color: text, letterSpacing: -0.5, fontVariantNumeric: 'tabular-nums' }}>
                  520<span style={{ fontFamily: SF, fontSize: 14, fontWeight: 500, color: muted, marginLeft: 3 }}>kcal</span>
                </div>
              </div>
            </div>
            <div style={{
              display: 'flex', alignItems: 'center', gap: 7, marginTop: 14, paddingTop: 14,
              borderTop: `0.5px solid ${dark ? 'rgba(84,84,88,0.4)' : HF.divider}`,
            }}>
              <OnbSparkle size={13} />
              <span style={{ fontFamily: SF, fontSize: 13, fontWeight: 500, color: muted, letterSpacing: -0.1 }}>
                Estimated by Apple Intelligence · editable
              </span>
            </div>
          </div>
        </div>

        {/* Steps */}
        <div style={{ padding: '18px 28px 0', display: 'flex', flexDirection: 'column', gap: 18 }}>
          {steps.map((s, i) => (
            <div key={i} style={{ display: 'flex', gap: 14, alignItems: 'flex-start' }}>
              <div style={{
                width: 26, height: 26, borderRadius: 13, flexShrink: 0,
                background: dark ? 'rgba(255,255,255,0.1)' : 'rgba(60,60,67,0.07)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: SFR, fontSize: 14, fontWeight: 600, color: text,
              }}>{i + 1}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: SF, fontSize: 16, fontWeight: 600, color: text, letterSpacing: -0.3 }}>{s.t}</div>
                <div style={{ fontFamily: SF, fontSize: 14, color: muted, letterSpacing: -0.15, lineHeight: 1.4, marginTop: 2, textWrap: 'pretty' }}>{s.d}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      <OnbFooter dark={dark} label="Continue" n={5} active={2} />
    </OnbShell>
  );
}

// ═══ 4 · WIDGETS ═══
function OnbWidgets({ dark = false }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;

  const tags = ['Home Screen', 'Lock Screen', 'StandBy'];

  return (
    <OnbShell dark={dark}>
      <OnbTopBar dark={dark} showSkip />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: '4px 28px 0' }}>
          <h1 style={{ fontFamily: SF, fontSize: 30, fontWeight: 700, color: text, letterSpacing: -0.6, margin: 0, textWrap: 'balance' }}>
            Keep it one glance away
          </h1>
          <p style={{ fontFamily: SF, fontSize: 16, color: muted, letterSpacing: -0.3, lineHeight: 1.45, margin: '10px 0 0', textWrap: 'pretty' }}>
            Add a widget to see your ring without opening the app — and log a meal in one tap.
          </p>
        </div>

        {/* Widget showcase on a wallpaper panel */}
        <div style={{ padding: '26px 20px 0' }}>
          <div style={{
            borderRadius: 28, padding: '26px 20px',
            background: dark
              ? 'linear-gradient(150deg, #2b3a55 0%, #1a2238 55%, #3d2f4d 100%)'
              : 'linear-gradient(150deg, #d9e2f0 0%, #e9e4ee 55%, #f3ece4 100%)',
            position: 'relative', overflow: 'hidden',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 18,
          }}>
            <div style={{
              position: 'absolute', inset: 0,
              background: 'radial-gradient(circle at 25% 15%, rgba(255,255,255,0.12), transparent 55%), radial-gradient(circle at 80% 90%, rgba(255,255,255,0.08), transparent 55%)',
              pointerEvents: 'none',
            }} />
            <div style={{ position: 'relative', transform: 'scale(0.96)' }}>
              <WidgetMedium dark={dark} />
            </div>
            <div style={{ position: 'relative' }}>
              <WidgetSmall dark={dark} />
            </div>
          </div>
        </div>

        {/* Placement tags */}
        <div style={{ padding: '18px 20px 0', display: 'flex', gap: 8, justifyContent: 'center', flexWrap: 'wrap' }}>
          {tags.map((t) => (
            <div key={t} style={{
              padding: '7px 14px', borderRadius: 16,
              background: dark ? 'rgba(255,255,255,0.08)' : 'rgba(60,60,67,0.06)',
              fontFamily: SF, fontSize: 13, fontWeight: 500, color: muted, letterSpacing: -0.1,
            }}>{t}</div>
          ))}
        </div>
      </div>

      <OnbFooter dark={dark} label="Continue" n={5} active={3} secondary="Add later from the widget gallery" />
    </OnbShell>
  );
}

// ═══ 5 · READY ═══
function OnbReady({ dark = false }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  const surface = dark ? HF.surfaceD : HF.surface;

  return (
    <OnbShell dark={dark}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px' }}>
        {/* Fresh ring */}
        <div style={{ position: 'relative', width: 200, height: 200, marginBottom: 36 }}>
          <AnimatedRing size={200} stroke={16} progress={0.001} color={dark ? HF.inkD : HF.ring} trackColor={dark ? 'rgba(255,255,255,0.08)' : HF.ringTrack} />
          <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
            <div style={{ fontFamily: SFR, fontSize: 13, fontWeight: 500, color: muted, letterSpacing: 0.5, textTransform: 'uppercase' }}>Eaten</div>
            <div style={{ fontFamily: SFR, fontSize: 52, fontWeight: 600, color: text, letterSpacing: -1.5, lineHeight: 1, marginTop: 2, fontVariantNumeric: 'tabular-nums' }}>0</div>
            <div style={{ fontFamily: SF, fontSize: 14, color: muted, marginTop: 6, letterSpacing: -0.08 }}>of 2,000 kcal</div>
          </div>
        </div>

        <h1 style={{ fontFamily: SF, fontSize: 32, fontWeight: 700, color: text, letterSpacing: -0.7, textAlign: 'center', margin: 0, textWrap: 'balance' }}>
          You’re all set
        </h1>
        <p style={{ fontFamily: SF, fontSize: 17, color: muted, letterSpacing: -0.3, lineHeight: 1.5, textAlign: 'center', margin: '16px 0 0', maxWidth: 300, textWrap: 'pretty' }}>
          Your ring starts fresh. Tap <span style={{ color: text, fontWeight: 600 }}>+</span> to log your first meal whenever you’re ready.
        </p>
      </div>

      <OnbFooter dark={dark} label="Start tracking" n={5} active={4} />
    </OnbShell>
  );
}

Object.assign(window, {
  OnbWelcome, OnbTarget, OnbEstimates, OnbWidgets, OnbReady,
});
