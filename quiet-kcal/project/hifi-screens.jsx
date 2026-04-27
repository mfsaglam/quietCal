// hifi-screens.jsx — High-fidelity iOS 26 screens for Quiet Kcal
// Uses IOSDevice, IOSGlassPill, IOSList, IOSListRow, IOSKeyboard from ios-frame.jsx

// ── Palette ──
const HF = {
  paper: '#FAFAF7',       // off-white (warm)
  surface: '#FFFFFF',
  ink: '#1A1A1A',
  ink2: '#2B2B2B',
  muted: 'rgba(60,60,67,0.6)',
  muted2: 'rgba(60,60,67,0.3)',
  divider: 'rgba(60,60,67,0.12)',
  ring: '#1A1A1A',
  ringTrack: 'rgba(60,60,67,0.1)',
  warn: '#C8422D',
  warnBg: 'rgba(200,66,45,0.08)',
  // dark
  paperD: '#000',
  surfaceD: '#1C1C1E',
  inkD: '#fff',
};

const SF = '-apple-system, "SF Pro Text", "SF Pro Display", system-ui, sans-serif';
const SFR = '"SF Pro Rounded", -apple-system, system-ui, sans-serif';

// ── Animated ring ──
function AnimatedRing({ size = 240, stroke = 18, progress = 0.62, color = HF.ring, trackColor = HF.ringTrack }) {
  const [p, setP] = React.useState(0);
  React.useEffect(() => {
    const t = setTimeout(() => setP(progress), 60);
    return () => clearTimeout(t);
  }, [progress]);
  const r = size / 2 - stroke / 2;
  const c = size / 2;
  const circ = 2 * Math.PI * r;
  return (
    <svg width={size} height={size} style={{ display: 'block' }}>
      <circle cx={c} cy={c} r={r} stroke={trackColor} strokeWidth={stroke} fill="none" />
      <circle cx={c} cy={c} r={r}
        stroke={color} strokeWidth={stroke} fill="none"
        strokeDasharray={`${circ * p} ${circ}`}
        strokeDashoffset={circ * 0.25}
        strokeLinecap="round"
        transform={`rotate(-90 ${c} ${c})`}
        style={{ transition: 'stroke-dasharray 900ms cubic-bezier(0.2, 0.8, 0.2, 1)' }}
      />
    </svg>
  );
}

// ── Meal row (hi-fi) ──
function MealRowHF({ name, grams, kcal, time, last, dark }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  const divider = dark ? 'rgba(84,84,88,0.4)' : HF.divider;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '14px 0', borderBottom: last ? 'none' : `0.5px solid ${divider}`,
    }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: SF, fontSize: 17, fontWeight: 500, color: text,
          letterSpacing: -0.4, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
        }}>{name}</div>
        <div style={{
          fontFamily: SF, fontSize: 13, color: muted,
          letterSpacing: -0.08, marginTop: 2,
        }}>{time} · {grams}g</div>
      </div>
      <div style={{
        fontFamily: SFR, fontSize: 17, fontWeight: 500, color: text,
        letterSpacing: -0.4, fontVariantNumeric: 'tabular-nums',
      }}>{kcal}</div>
    </div>
  );
}

// ═══ HOME — Ring ═══
function HifiHome({ over = false, dark = false }) {
  const eaten = over ? 2180 : 1240;
  const target = 2000;
  const progress = Math.min(eaten / target, 1);
  const rawProgress = eaten / target;
  const remaining = target - eaten;
  const ringColor = over ? HF.warn : (dark ? HF.inkD : HF.ring);
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  const surface = dark ? HF.surfaceD : HF.surface;
  const paper = dark ? HF.paperD : HF.paper;

  const meals = over ? [
    { name: 'Oatmeal with berries', grams: 220, kcal: 310, time: '08:15' },
    { name: 'Pasta carbonara', grams: 420, kcal: 890, time: '12:45' },
    { name: 'Dark chocolate', grams: 100, kcal: 540, time: '15:20' },
    { name: 'Rice & beans bowl', grams: 300, kcal: 440, time: '19:10' },
  ] : [
    { name: 'Oatmeal with berries', grams: 220, kcal: 310, time: '08:15' },
    { name: 'Chicken salad', grams: 340, kcal: 520, time: '12:45' },
    { name: 'Apple', grams: 180, kcal: 95, time: '15:20' },
    { name: 'Coffee with milk', grams: 240, kcal: 80, time: '16:10' },
  ];
  const total = meals.reduce((s, m) => s + m.kcal, 0);

  return (
    <div style={{ background: paper, minHeight: '100%', paddingTop: 54, paddingBottom: 120 }}>
      {/* Top bar */}
      <div style={{
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        padding: '12px 20px 4px',
      }}>
        <div>
          <div style={{
            fontFamily: SF, fontSize: 13, fontWeight: 500,
            color: muted, letterSpacing: 0.5, textTransform: 'uppercase',
          }}>Thursday · Apr 18</div>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          <IOSGlassPill dark={dark}>
            <div style={{ padding: '0 14px', height: 36, display: 'flex', alignItems: 'center', gap: 6 }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                <circle cx="12" cy="12" r="9" stroke={text} strokeWidth="1.8"/>
                <path d="M12 7v5l3 2" stroke={text} strokeWidth="1.8" strokeLinecap="round"/>
              </svg>
              <span style={{ fontFamily: SF, fontSize: 15, fontWeight: 500, color: text }}>History</span>
            </div>
          </IOSGlassPill>
          <IOSGlassPill dark={dark}>
            <div style={{ width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                <path d="M12 15.5a3.5 3.5 0 100-7 3.5 3.5 0 000 7z" stroke={text} strokeWidth="1.6"/>
                <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 11-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 008.07 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H2a2 2 0 010-4h.09a1.65 1.65 0 001.51-1 1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H8a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 112.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" stroke={text} strokeWidth="1.4" strokeLinejoin="round"/>
              </svg>
            </div>
          </IOSGlassPill>
        </div>
      </div>

      <div style={{ padding: '4px 20px 0' }}>
        <h1 style={{
          fontFamily: SF, fontSize: 34, fontWeight: 700, color: text,
          letterSpacing: 0.4, margin: '4px 0 20px',
        }}>Today</h1>
      </div>

      {/* Ring */}
      <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 24px' }}>
        <div style={{ position: 'relative', width: 240, height: 240 }}>
          <AnimatedRing size={240} stroke={18} progress={Math.min(rawProgress, 1)} color={ringColor} trackColor={dark ? 'rgba(255,255,255,0.08)' : HF.ringTrack} />
          <div style={{
            position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'center',
          }}>
            <div style={{
              fontFamily: SFR, fontSize: 13, fontWeight: 500,
              color: muted, letterSpacing: 0.5, textTransform: 'uppercase',
            }}>{over ? 'Over by' : 'Eaten'}</div>
            <div style={{
              fontFamily: SFR, fontSize: 52, fontWeight: 600,
              color: over ? HF.warn : text,
              letterSpacing: -1.5, lineHeight: 1,
              fontVariantNumeric: 'tabular-nums',
              marginTop: 2,
            }}>{over ? `+${eaten - target}` : eaten.toLocaleString()}</div>
            <div style={{
              fontFamily: SF, fontSize: 14, color: muted, marginTop: 6, letterSpacing: -0.08,
            }}>{over ? `${eaten.toLocaleString()} / ${target.toLocaleString()} kcal` : `of ${target.toLocaleString()} kcal`}</div>
          </div>
        </div>
      </div>

      {/* Stat strip */}
      <div style={{ padding: '0 20px 20px' }}>
        <div style={{
          background: surface, borderRadius: 22,
          padding: '16px 20px', display: 'flex', justifyContent: 'space-between',
        }}>
          {[
            { label: 'Target', value: target.toLocaleString() },
            { label: over ? 'Over' : 'Remaining', value: over ? `+${eaten - target}` : remaining.toLocaleString(), warn: over },
            { label: 'Meals', value: meals.length },
          ].map((s, i) => (
            <div key={i} style={{ textAlign: 'center', flex: 1 }}>
              <div style={{
                fontFamily: SFR, fontSize: 22, fontWeight: 600,
                color: s.warn ? HF.warn : text, letterSpacing: -0.5,
                fontVariantNumeric: 'tabular-nums',
              }}>{s.value}</div>
              <div style={{
                fontFamily: SF, fontSize: 11, color: muted,
                letterSpacing: 0.5, textTransform: 'uppercase', marginTop: 2, fontWeight: 500,
              }}>{s.label}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Meals list */}
      <div style={{ padding: '0 20px' }}>
        <div style={{
          fontFamily: SF, fontSize: 13, color: muted,
          letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500,
          padding: '8px 4px',
        }}>Meals · {total.toLocaleString()} kcal</div>
        <div style={{ background: surface, borderRadius: 22, padding: '4px 18px' }}>
          {meals.map((m, i) => (
            <MealRowHF key={i} {...m} last={i === meals.length - 1} dark={dark} />
          ))}
        </div>
      </div>
    </div>
  );
}

// Floating + (outside content)
function HifiFAB({ dark = false }) {
  return (
    <div style={{
      position: 'absolute', bottom: 52, right: 20, zIndex: 40,
      width: 60, height: 60, borderRadius: 30, overflow: 'hidden',
      boxShadow: dark
        ? '0 8px 24px rgba(0,0,0,0.5), 0 2px 6px rgba(0,0,0,0.3)'
        : '0 8px 24px rgba(0,0,0,0.18), 0 2px 6px rgba(0,0,0,0.1)',
    }}>
      {/* liquid glass: blur + tint */}
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 30,
        backdropFilter: 'blur(20px) saturate(180%)',
        WebkitBackdropFilter: 'blur(20px) saturate(180%)',
        background: dark ? 'rgba(120,120,128,0.35)' : 'rgba(255,255,255,0.55)',
      }} />
      {/* shine / inner highlight */}
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 30,
        boxShadow: dark
          ? 'inset 1.5px 1.5px 1px rgba(255,255,255,0.22), inset -1px -1px 1px rgba(255,255,255,0.08)'
          : 'inset 1.5px 1.5px 1px rgba(255,255,255,0.9), inset -1px -1px 1px rgba(255,255,255,0.5)',
        border: dark ? '0.5px solid rgba(255,255,255,0.18)' : '0.5px solid rgba(0,0,0,0.06)',
        pointerEvents: 'none',
      }} />
      {/* specular sheen */}
      <div style={{
        position: 'absolute', top: 3, left: 8, right: 8, height: 18, borderRadius: 12,
        background: dark
          ? 'linear-gradient(180deg, rgba(255,255,255,0.28), rgba(255,255,255,0) 80%)'
          : 'linear-gradient(180deg, rgba(255,255,255,0.75), rgba(255,255,255,0) 80%)',
        pointerEvents: 'none',
      }} />
      <div style={{
        position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
          <path d="M12 5v14M5 12h14"
            stroke={dark ? '#fff' : HF.ink}
            strokeWidth="2.2" strokeLinecap="round"/>
        </svg>
      </div>
    </div>
  );
}

// ═══ ADD MEAL — sheet ═══
// state: 'empty' | 'estimating' | 'estimated'
function HifiAddMeal({ dark = false, state = 'estimated' }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  const surface = dark ? HF.surfaceD : HF.surface;
  const paper = dark ? HF.paperD : HF.paper;
  const fieldBg = dark ? 'rgba(118,118,128,0.24)' : 'rgba(118,118,128,0.08)';

  // Apple Intelligence accent (system purple/pink)
  const aiPurple = '#AF52DE';
  const aiPink = '#FF2D92';

  // Sparkle (Apple Intelligence) glyph
  const Sparkle = ({ size = 13, c1 = aiPurple, c2 = aiPink }) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <defs>
        <linearGradient id="aigr" x1="0" y1="0" x2="24" y2="24">
          <stop offset="0" stopColor={c1}/>
          <stop offset="1" stopColor={c2}/>
        </linearGradient>
      </defs>
      <path d="M12 2l2.2 5.8L20 10l-5.8 2.2L12 18l-2.2-5.8L4 10l5.8-2.2L12 2z" fill="url(#aigr)"/>
      <circle cx="19" cy="5" r="1.4" fill="url(#aigr)"/>
      <circle cx="5" cy="20" r="1.1" fill="url(#aigr)"/>
    </svg>
  );

  const renderCalField = () => {
    if (state === 'empty') {
      return (
        <div style={{ flex: 1, background: surface, borderRadius: 14, padding: '12px 16px' }}>
          <div style={{ fontFamily: SF, fontSize: 11, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500, marginBottom: 4, display: 'flex', alignItems: 'center', gap: 4 }}>
            <Sparkle size={11} /> Calories
          </div>
          <div style={{ fontFamily: SFR, fontSize: 22, fontWeight: 600, color: muted, letterSpacing: -0.5, fontVariantNumeric: 'tabular-nums' }}>
            —<span style={{ fontFamily: SF, fontSize: 15, fontWeight: 500, color: muted, marginLeft: 4 }}>kcal</span>
          </div>
        </div>
      );
    }
    if (state === 'estimating') {
      return (
        <div style={{ flex: 1, background: surface, borderRadius: 14, padding: '12px 16px', position: 'relative', overflow: 'hidden' }}>
          <div style={{ fontFamily: SF, fontSize: 11, color: aiPurple, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 600, marginBottom: 4, display: 'flex', alignItems: 'center', gap: 4 }}>
            <Sparkle size={11} /> Estimating…
          </div>
          <div style={{
            height: 28, borderRadius: 6,
            background: dark
              ? 'linear-gradient(90deg, rgba(175,82,222,0.25), rgba(255,45,146,0.25), rgba(175,82,222,0.25))'
              : 'linear-gradient(90deg, rgba(175,82,222,0.18), rgba(255,45,146,0.18), rgba(175,82,222,0.18))',
            backgroundSize: '200% 100%',
            animation: 'shimmer 1.6s linear infinite',
          }} />
        </div>
      );
    }
    // estimated
    return (
      <div style={{ flex: 1, background: surface, borderRadius: 14, padding: '12px 16px', position: 'relative' }}>
        <div style={{ fontFamily: SF, fontSize: 11, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500, marginBottom: 4, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Sparkle size={11} /> Calories
        </div>
        <div style={{ fontFamily: SFR, fontSize: 22, fontWeight: 600, color: text, letterSpacing: -0.5, fontVariantNumeric: 'tabular-nums' }}>
          520<span style={{ fontFamily: SF, fontSize: 15, fontWeight: 500, color: muted, marginLeft: 4 }}>kcal</span>
        </div>
      </div>
    );
  };

  return (
    <div style={{
      background: paper, minHeight: '100%', position: 'relative',
      paddingTop: 54,
    }}>
      {/* Dimmed home peek */}
      <div style={{ opacity: 0.3, padding: '0 20px', pointerEvents: 'none' }}>
        <div style={{ fontFamily: SF, fontSize: 13, fontWeight: 500, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', padding: '12px 0' }}>Thursday · Apr 18</div>
        <div style={{ fontFamily: SF, fontSize: 34, fontWeight: 700, color: text, letterSpacing: 0.4 }}>Today</div>
        <div style={{ display: 'flex', justifyContent: 'center', marginTop: 20 }}>
          <AnimatedRing size={180} stroke={14} progress={0.62} color={text} trackColor={HF.ringTrack} />
        </div>
      </div>

      {/* Scrim */}
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.35)', pointerEvents: 'none' }} />

      {/* Sheet */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, height: '78%',
        background: paper, borderTopLeftRadius: 14, borderTopRightRadius: 14,
        boxShadow: '0 -4px 20px rgba(0,0,0,0.08)',
        display: 'flex', flexDirection: 'column',
      }}>
        {/* Grabber */}
        <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 4px' }}>
          <div style={{ width: 36, height: 5, borderRadius: 3, background: 'rgba(60,60,67,0.3)' }} />
        </div>
        {/* Header */}
        <div style={{
          display: 'flex', alignItems: 'center',
          padding: '8px 16px 16px',
        }}>
          <div style={{ flex: 1, textAlign: 'left' }}>
            <span style={{ fontFamily: SF, fontSize: 17, color: '#007AFF', letterSpacing: -0.4, whiteSpace: 'nowrap' }}>Cancel</span>
          </div>
          <div style={{ flex: 1, textAlign: 'center' }}>
            <span style={{ fontFamily: SF, fontSize: 17, fontWeight: 600, color: text, letterSpacing: -0.4, whiteSpace: 'nowrap' }}>New Meal</span>
          </div>
          <div style={{ flex: 1, textAlign: 'right' }}>
            <span style={{
              fontFamily: SF, fontSize: 17, fontWeight: 600,
              color: state === 'estimated' ? '#007AFF' : 'rgba(0,122,255,0.35)',
              letterSpacing: -0.4, whiteSpace: 'nowrap',
            }}>Save</span>
          </div>
        </div>

        {/* Fields */}
        <div style={{ padding: '0 16px', flex: 1 }}>
          {/* Name */}
          <div style={{ background: surface, borderRadius: 14, padding: '12px 16px', marginBottom: 16 }}>
            <div style={{ fontFamily: SF, fontSize: 11, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500, marginBottom: 4 }}>Name</div>
            <div style={{ display: 'flex', alignItems: 'center', whiteSpace: 'nowrap', overflow: 'hidden' }}>
              {state === 'empty' ? (
                <>
                  <span style={{ fontFamily: SF, fontSize: 17, color: text, letterSpacing: -0.4 }}>Chick</span>
                  <span style={{ display: 'inline-block', width: 2, height: 20, background: '#007AFF', marginLeft: 1, animation: 'blink 1.1s infinite', flexShrink: 0 }} />
                </>
              ) : (
                <span style={{ fontFamily: SF, fontSize: 17, color: text, letterSpacing: -0.4 }}>Chicken salad</span>
              )}
            </div>
          </div>

          {/* Grams + Kcal */}
          <div style={{ display: 'flex', gap: 10, marginBottom: 12 }}>
            <div style={{ flex: 1, background: surface, borderRadius: 14, padding: '12px 16px' }}>
              <div style={{ fontFamily: SF, fontSize: 11, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500, marginBottom: 4 }}>Amount</div>
              <div style={{ fontFamily: SFR, fontSize: 22, fontWeight: 600, color: state === 'empty' ? muted : text, letterSpacing: -0.5, fontVariantNumeric: 'tabular-nums' }}>
                {state === 'empty' ? '—' : '340'}
                <span style={{ fontFamily: SF, fontSize: 15, fontWeight: 500, color: muted, marginLeft: 4 }}>g</span>
              </div>
            </div>
            {renderCalField()}
          </div>

          {/* AI estimate chip — only when estimated */}
          {state === 'estimated' && (
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8,
              padding: '10px 12px', borderRadius: 12,
              background: dark ? 'rgba(175,82,222,0.15)' : 'rgba(175,82,222,0.08)',
              border: `0.5px solid ${dark ? 'rgba(175,82,222,0.4)' : 'rgba(175,82,222,0.25)'}`,
              marginBottom: 14,
            }}>
              <Sparkle size={14} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontFamily: SF, fontSize: 13, fontWeight: 600, color: text, letterSpacing: -0.1 }}>
                  Estimated by Apple Intelligence
                </div>
                <div style={{ fontFamily: SF, fontSize: 11, color: muted, marginTop: 1, letterSpacing: -0.05 }}>
                  Medium confidence · tap to edit or retry
                </div>
              </div>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                <path d="M3 12a9 9 0 0115.5-6.3M21 4v5h-5M21 12a9 9 0 01-15.5 6.3M3 20v-5h5" stroke={aiPurple} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </div>
          )}

          {/* Unit segmented */}
          <div style={{ padding: '4px 0 0' }}>
            <div style={{ fontFamily: SF, fontSize: 11, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500, marginBottom: 6, paddingLeft: 4 }}>Unit</div>
            <div style={{
              display: 'flex', background: fieldBg, borderRadius: 9, padding: 2,
            }}>
              {['g', 'oz', 'lb'].map((u, i) => (
                <div key={u} style={{
                  flex: 1, textAlign: 'center', padding: '7px 0',
                  background: i === 0 ? surface : 'transparent',
                  borderRadius: 7,
                  fontFamily: SF, fontSize: 13, fontWeight: i === 0 ? 600 : 500,
                  color: text, letterSpacing: -0.08,
                  boxShadow: i === 0 ? '0 2px 6px rgba(0,0,0,0.05), 0 0 0 0.5px rgba(0,0,0,0.04)' : 'none',
                }}>{u}</div>
              ))}
            </div>
          </div>
        </div>

        {/* Fake numpad bar */}
        <IOSKeyboard dark={dark} />
      </div>

      <style>{`
        @keyframes blink { 0%, 50% { opacity: 1; } 51%, 100% { opacity: 0; } }
        @keyframes shimmer {
          0% { background-position: 200% 0; }
          100% { background-position: -200% 0; }
        }
      `}</style>
    </div>
  );
}

// ═══ HISTORY ═══
function HifiHistory({ dark = false }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  const surface = dark ? HF.surfaceD : HF.surface;
  const paper = dark ? HF.paperD : HF.paper;

  const week = [
    { d: 'F', kcal: 1810, pct: 0.9 },
    { d: 'S', kcal: 1600, pct: 0.8 },
    { d: 'S', kcal: 2040, pct: 1.02, over: true },
    { d: 'M', kcal: 1720, pct: 0.86 },
    { d: 'T', kcal: 2150, pct: 1.07, over: true },
    { d: 'W', kcal: 1890, pct: 0.94 },
    { d: 'T', kcal: 1240, pct: 0.62, today: true },
  ];
  const days = [
    { d: 'Wednesday', date: 'Apr 17', kcal: 1890, pct: 0.94 },
    { d: 'Tuesday', date: 'Apr 16', kcal: 2150, pct: 1.07, over: true },
    { d: 'Monday', date: 'Apr 15', kcal: 1720, pct: 0.86 },
    { d: 'Sunday', date: 'Apr 14', kcal: 2040, pct: 1.02, over: true },
    { d: 'Saturday', date: 'Apr 13', kcal: 1600, pct: 0.8 },
    { d: 'Friday', date: 'Apr 12', kcal: 1950, pct: 0.97 },
  ];

  return (
    <div style={{ background: paper, minHeight: '100%', paddingTop: 54, paddingBottom: 120 }}>
      <div style={{ padding: '12px 20px 4px' }}>
        <div style={{ fontFamily: SF, fontSize: 13, fontWeight: 500, color: muted, letterSpacing: 0.5, textTransform: 'uppercase' }}>
          Average · 1,808 kcal
        </div>
        <h1 style={{ fontFamily: SF, fontSize: 34, fontWeight: 700, color: text, letterSpacing: 0.4, margin: '4px 0 20px' }}>History</h1>
      </div>

      {/* Week chart */}
      <div style={{ padding: '0 20px 16px' }}>
        <div style={{
          background: surface, borderRadius: 22, padding: '20px 18px 16px',
        }}>
          <div style={{ display: 'flex', alignItems: 'flex-end', gap: 8, height: 130 }}>
            {week.map((w, i) => (
              <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
                <div style={{
                  width: '100%', height: `${Math.min(w.pct, 1.1) * 100}px`,
                  background: w.over ? HF.warn : (w.today ? text : (dark ? 'rgba(255,255,255,0.85)' : HF.ink)),
                  opacity: w.today ? 1 : 0.85,
                  borderRadius: 6,
                  position: 'relative',
                }}>
                  {w.today && (
                    <div style={{
                      position: 'absolute', bottom: '100%', left: '50%', transform: 'translateX(-50%)',
                      fontFamily: SFR, fontSize: 11, fontWeight: 600, color: text,
                      marginBottom: 4, fontVariantNumeric: 'tabular-nums',
                    }}>{w.kcal.toLocaleString()}</div>
                  )}
                </div>
                <div style={{ fontFamily: SF, fontSize: 12, fontWeight: w.today ? 700 : 500, color: w.today ? text : muted }}>
                  {w.d}
                </div>
              </div>
            ))}
          </div>
          {/* target line marker */}
          <div style={{
            fontFamily: SF, fontSize: 11, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500,
            marginTop: 14, display: 'flex', justifyContent: 'space-between',
          }}>
            <span>This week</span>
            <span style={{ fontVariantNumeric: 'tabular-nums' }}>Target 2,000</span>
          </div>
        </div>
      </div>

      {/* Day list */}
      <div style={{ padding: '0 20px' }}>
        <div style={{
          fontFamily: SF, fontSize: 13, color: muted,
          letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500,
          padding: '8px 4px',
        }}>Earlier</div>
        <div style={{ background: surface, borderRadius: 22, padding: '4px 18px' }}>
          {days.map((day, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '14px 0',
              borderBottom: i === days.length - 1 ? 'none' : `0.5px solid ${HF.divider}`,
            }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: SF, fontSize: 17, fontWeight: 500, color: text, letterSpacing: -0.4 }}>
                  {day.d}
                </div>
                <div style={{ fontFamily: SF, fontSize: 13, color: muted, letterSpacing: -0.08, marginTop: 2 }}>
                  {day.date}
                </div>
              </div>
              <div style={{
                fontFamily: SFR, fontSize: 17, fontWeight: 500,
                color: day.over ? HF.warn : text,
                letterSpacing: -0.4, fontVariantNumeric: 'tabular-nums',
              }}>{day.kcal.toLocaleString()}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ═══ SETTINGS ═══
function HifiSettings({ dark = false }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  const surface = dark ? HF.surfaceD : HF.surface;
  const paper = dark ? HF.paperD : HF.paper;

  const Section = ({ header, children }) => (
    <div style={{ marginBottom: 28 }}>
      {header && (
        <div style={{
          fontFamily: SF, fontSize: 13, color: muted,
          letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500,
          padding: '0 4px 8px',
        }}>{header}</div>
      )}
      <div style={{ background: surface, borderRadius: 22, overflow: 'hidden' }}>
        {children}
      </div>
    </div>
  );
  const Row = ({ label, value, chev = true, danger, last }) => (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '14px 18px',
      borderBottom: last ? 'none' : `0.5px solid ${HF.divider}`,
    }}>
      <div style={{ flex: 1, fontFamily: SF, fontSize: 17, color: danger ? HF.warn : text, letterSpacing: -0.4 }}>{label}</div>
      {value && <div style={{ fontFamily: SF, fontSize: 17, color: muted, letterSpacing: -0.4 }}>{value}</div>}
      {chev && !danger && (
        <svg width="7" height="12" viewBox="0 0 7 12">
          <path d="M1 1l5 5-5 5" stroke={muted} strokeWidth="1.8" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      )}
    </div>
  );

  return (
    <div style={{ background: paper, minHeight: '100%', paddingTop: 54, paddingBottom: 120 }}>
      <div style={{ padding: '12px 20px 20px' }}>
        <h1 style={{ fontFamily: SF, fontSize: 34, fontWeight: 700, color: text, letterSpacing: 0.4, margin: '4px 0 0' }}>Settings</h1>
      </div>
      <div style={{ padding: '0 20px' }}>
        <Section header="Intelligence">
          <Row label="Auto-estimate calories" value="On" />
          <Row label="Cloud fallback" value="Off" last />
        </Section>
        <Section header="Daily Target">
          <Row label="Calorie target" value="2,000 kcal" />
          <Row label="Weight unit" value="Grams" last />
        </Section>
        <Section header="Appearance">
          <Row label="Theme" value="System" />
          <Row label="Accent" value="Ink" last />
        </Section>
        <Section header="Data">
          <Row label="Export CSV" />
          <Row label="Reset today" />
          <Row label="Clear all data" chev={false} danger last />
        </Section>
        <div style={{ textAlign: 'center', padding: '16px 0' }}>
          <div style={{ fontFamily: SF, fontSize: 13, color: muted, letterSpacing: -0.08 }}>Quiet Kcal · v1.0</div>
        </div>
      </div>
    </div>
  );
}

// ═══ EDIT TARGET ═══
function HifiEditTarget({ dark = false }) {
  const text = dark ? HF.inkD : HF.ink;
  const muted = dark ? 'rgba(235,235,245,0.6)' : HF.muted;
  const surface = dark ? HF.surfaceD : HF.surface;
  const paper = dark ? HF.paperD : HF.paper;
  const fieldBg = dark ? 'rgba(118,118,128,0.24)' : 'rgba(118,118,128,0.08)';

  return (
    <div style={{ background: paper, minHeight: '100%', paddingTop: 54, paddingBottom: 40 }}>
      {/* nav */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '8px 20px 4px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 4, color: '#007AFF' }}>
          <svg width="10" height="16" viewBox="0 0 10 16"><path d="M8 1L2 8l6 7" stroke="#007AFF" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
          <span style={{ fontFamily: SF, fontSize: 17, letterSpacing: -0.4 }}>Settings</span>
        </div>
        <span style={{ fontFamily: SF, fontSize: 17, fontWeight: 600, color: '#007AFF', letterSpacing: -0.4 }}>Done</span>
      </div>

      <div style={{ padding: '8px 20px' }}>
        <h1 style={{ fontFamily: SF, fontSize: 34, fontWeight: 700, color: text, letterSpacing: 0.4, margin: '4px 0 4px' }}>Daily target</h1>
        <div style={{ fontFamily: SF, fontSize: 15, color: muted, letterSpacing: -0.2 }}>
          How many calories per day?
        </div>
      </div>

      {/* Big numeric display */}
      <div style={{ padding: '40px 20px 24px', textAlign: 'center' }}>
        <div style={{
          fontFamily: SFR, fontSize: 96, fontWeight: 600,
          color: text, letterSpacing: -3, lineHeight: 1,
          fontVariantNumeric: 'tabular-nums',
        }}>2,000</div>
        <div style={{ fontFamily: SF, fontSize: 13, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500, marginTop: 6 }}>kcal per day</div>
      </div>

      {/* Slider */}
      <div style={{ padding: '24px 20px 0' }}>
        <div style={{ background: surface, borderRadius: 22, padding: '22px 20px' }}>
          <div style={{ position: 'relative', height: 28 }}>
            <div style={{
              position: 'absolute', top: 12, left: 0, right: 0, height: 4,
              borderRadius: 2, background: fieldBg,
            }} />
            <div style={{
              position: 'absolute', top: 12, left: 0, width: '35%', height: 4,
              borderRadius: 2, background: text,
            }} />
            <div style={{
              position: 'absolute', top: 0, left: 'calc(35% - 14px)',
              width: 28, height: 28, borderRadius: 14, background: '#fff',
              boxShadow: '0 3px 8px rgba(0,0,0,0.15), 0 0 0 0.5px rgba(0,0,0,0.04)',
            }} />
          </div>
          <div style={{
            display: 'flex', justifyContent: 'space-between',
            fontFamily: SF, fontSize: 12, color: muted, marginTop: 10, fontVariantNumeric: 'tabular-nums',
          }}>
            <span>1,200</span>
            <span>3,500</span>
          </div>
        </div>
      </div>

      {/* Presets */}
      <div style={{ padding: '20px 20px 0' }}>
        <div style={{ fontFamily: SF, fontSize: 13, color: muted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 500, padding: '0 4px 8px' }}>Quick pick</div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
          {[
            { v: '1,500' }, { v: '1,800' }, { v: '2,000', active: true }, { v: '2,200' }, { v: '2,500' }, { v: '2,800' },
          ].map((p) => (
            <div key={p.v} style={{
              padding: '10px 18px', borderRadius: 18,
              background: p.active ? text : surface,
              color: p.active ? paper : text,
              fontFamily: SF, fontSize: 15, fontWeight: 500, letterSpacing: -0.2,
              fontVariantNumeric: 'tabular-nums',
            }}>{p.v}</div>
          ))}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  HF, SF, SFR,
  AnimatedRing, MealRowHF, HifiFAB,
  HifiHome, HifiAddMeal, HifiHistory, HifiSettings, HifiEditTarget,
});
