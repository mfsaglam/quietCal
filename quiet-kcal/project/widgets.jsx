// widgets.jsx — iOS 26 home/lock screen widgets for Quiet Kcal

const W_SF = '-apple-system, "SF Pro Text", system-ui, sans-serif';
const W_SFR = '"SF Pro Rounded", -apple-system, system-ui, sans-serif';

// Mini ring
function WRing({ size, stroke, progress, color, track }) {
  const r = size / 2 - stroke / 2;
  const c = size / 2;
  const circ = 2 * Math.PI * r;
  return (
    <svg width={size} height={size} style={{ display: 'block' }}>
      <circle cx={c} cy={c} r={r} stroke={track} strokeWidth={stroke} fill="none" />
      <circle cx={c} cy={c} r={r} stroke={color} strokeWidth={stroke} fill="none"
        strokeDasharray={`${circ * progress} ${circ}`}
        strokeDashoffset={circ * 0.25}
        strokeLinecap="round"
        transform={`rotate(-90 ${c} ${c})`} />
    </svg>
  );
}

// ── SMALL WIDGET (158×158) — ring + numbers
function WidgetSmall({ dark = false, over = false }) {
  const eaten = over ? 2180 : 1240;
  const target = 2000;
  const remaining = target - eaten;
  const text = dark ? '#fff' : '#1a1a1a';
  const muted = dark ? 'rgba(235,235,245,0.6)' : 'rgba(60,60,67,0.6)';
  const bg = dark ? '#1C1C1E' : '#FFFFFF';
  const ring = over ? '#C8422D' : (dark ? '#fff' : '#1a1a1a');
  const track = dark ? 'rgba(255,255,255,0.1)' : 'rgba(60,60,67,0.1)';

  return (
    <div style={{
      width: 158, height: 158, borderRadius: 22, background: bg,
      padding: 14, boxSizing: 'border-box', position: 'relative',
      boxShadow: '0 4px 14px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.06)',
      fontFamily: W_SF,
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div style={{
          fontSize: 10, fontWeight: 600, color: muted, letterSpacing: 0.5, textTransform: 'uppercase',
        }}>Today</div>
      </div>
      <div style={{ display: 'flex', justifyContent: 'center', marginTop: 4 }}>
        <div style={{ position: 'relative', width: 96, height: 96 }}>
          <WRing size={96} stroke={9} progress={Math.min(eaten / target, 1)} color={ring} track={track} />
          <div style={{
            position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'center',
          }}>
            <div style={{
              fontFamily: W_SFR, fontSize: 22, fontWeight: 700,
              color: over ? '#C8422D' : text, letterSpacing: -1, lineHeight: 1,
              fontVariantNumeric: 'tabular-nums',
            }}>{eaten.toLocaleString()}</div>
            <div style={{ fontSize: 9, color: muted, marginTop: 1, letterSpacing: 0.2 }}>
              of {target.toLocaleString()}
            </div>
          </div>
        </div>
      </div>
      <div style={{
        position: 'absolute', bottom: 12, left: 14, right: 14,
        textAlign: 'center', fontSize: 11, color: muted, fontWeight: 500,
      }}>
        {over ? `+${eaten - target} over` : `${remaining.toLocaleString()} kcal left`}
      </div>
    </div>
  );
}

// ── MEDIUM WIDGET (338×158) — ring + log meal button
function WidgetMedium({ dark = false }) {
  const eaten = 1240, target = 2000;
  const remaining = target - eaten;
  const text = dark ? '#fff' : '#1a1a1a';
  const muted = dark ? 'rgba(235,235,245,0.6)' : 'rgba(60,60,67,0.6)';
  const bg = dark ? '#1C1C1E' : '#FFFFFF';
  const ring = dark ? '#fff' : '#1a1a1a';
  const track = dark ? 'rgba(255,255,255,0.1)' : 'rgba(60,60,67,0.1)';
  const btnBg = dark ? '#fff' : '#1a1a1a';
  const btnTxt = dark ? '#1a1a1a' : '#fff';

  return (
    <div style={{
      width: 338, height: 158, borderRadius: 22, background: bg,
      padding: 16, boxSizing: 'border-box', position: 'relative',
      boxShadow: '0 4px 14px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.06)',
      display: 'flex', alignItems: 'center', gap: 16, fontFamily: W_SF,
    }}>
      {/* Ring */}
      <div style={{ position: 'relative', width: 110, height: 110, flexShrink: 0 }}>
        <WRing size={110} stroke={10} progress={eaten / target} color={ring} track={track} />
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center',
        }}>
          <div style={{
            fontFamily: W_SFR, fontSize: 24, fontWeight: 700, color: text,
            letterSpacing: -1, lineHeight: 1, fontVariantNumeric: 'tabular-nums',
          }}>{eaten.toLocaleString()}</div>
          <div style={{ fontSize: 10, color: muted, marginTop: 2 }}>
            of {target.toLocaleString()}
          </div>
        </div>
      </div>

      {/* Right column */}
      <div style={{ flex: 1, height: '100%', display: 'flex', flexDirection: 'column', justifyContent: 'space-between', paddingTop: 4, paddingBottom: 2 }}>
        <div>
          <div style={{
            fontSize: 10, fontWeight: 600, color: muted, letterSpacing: 0.5, textTransform: 'uppercase',
          }}>Today · Apr 18</div>
          <div style={{
            fontFamily: W_SFR, fontSize: 26, fontWeight: 700, color: text,
            letterSpacing: -0.5, marginTop: 2, fontVariantNumeric: 'tabular-nums',
          }}>{remaining.toLocaleString()}</div>
          <div style={{ fontSize: 11, color: muted, marginTop: -2 }}>kcal remaining</div>
        </div>
        {/* Log meal button — App Intent */}
        <div style={{
          background: btnBg, borderRadius: 12, padding: '8px 12px',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
        }}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
            <path d="M12 5v14M5 12h14" stroke={btnTxt} strokeWidth="2.4" strokeLinecap="round"/>
          </svg>
          <span style={{ fontSize: 13, fontWeight: 600, color: btnTxt, letterSpacing: -0.1 }}>
            Log meal
          </span>
        </div>
      </div>
    </div>
  );
}

// ── LOCK SCREEN — circular complication
function WidgetLockCircular({ dark = true }) {
  const eaten = 1240, target = 2000;
  return (
    <div style={{
      width: 76, height: 76, borderRadius: 38,
      background: 'rgba(255,255,255,0.18)',
      backdropFilter: 'blur(20px)',
      WebkitBackdropFilter: 'blur(20px)',
      border: '0.5px solid rgba(255,255,255,0.3)',
      position: 'relative',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontFamily: W_SF,
    }}>
      <div style={{ position: 'absolute', inset: 4 }}>
        <WRing size={68} stroke={5} progress={eaten / target} color="#fff" track="rgba(255,255,255,0.3)" />
      </div>
      <div style={{ position: 'relative', textAlign: 'center', color: '#fff' }}>
        <div style={{
          fontFamily: W_SFR, fontSize: 16, fontWeight: 700, lineHeight: 1,
          fontVariantNumeric: 'tabular-nums',
        }}>1.2k</div>
        <div style={{ fontSize: 8, opacity: 0.85, marginTop: 1 }}>kcal</div>
      </div>
    </div>
  );
}

// ── LOCK SCREEN — rectangular
function WidgetLockRect() {
  const eaten = 1240, target = 2000, remaining = target - eaten;
  return (
    <div style={{
      width: 172, height: 76, borderRadius: 16,
      background: 'rgba(255,255,255,0.15)',
      backdropFilter: 'blur(20px)',
      WebkitBackdropFilter: 'blur(20px)',
      border: '0.5px solid rgba(255,255,255,0.25)',
      padding: '10px 12px', boxSizing: 'border-box',
      display: 'flex', alignItems: 'center', gap: 10,
      fontFamily: W_SF, color: '#fff',
    }}>
      <div style={{ position: 'relative', width: 52, height: 52, flexShrink: 0 }}>
        <WRing size={52} stroke={5} progress={eaten / target} color="#fff" track="rgba(255,255,255,0.3)" />
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: W_SFR, fontSize: 11, fontWeight: 700,
        }}>62%</div>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 9, opacity: 0.75, fontWeight: 600, letterSpacing: 0.5, textTransform: 'uppercase' }}>Quiet Kcal</div>
        <div style={{
          fontFamily: W_SFR, fontSize: 22, fontWeight: 700, letterSpacing: -0.5, marginTop: 1, lineHeight: 1.05,
          fontVariantNumeric: 'tabular-nums',
        }}>{remaining.toLocaleString()}</div>
        <div style={{ fontSize: 10, opacity: 0.85 }}>kcal left</div>
      </div>
    </div>
  );
}

// Wallpaper swatch behind lock-screen widgets
function LockBg({ children, w = 360, h = 200 }) {
  return (
    <div style={{
      width: w, height: h, borderRadius: 24, position: 'relative', overflow: 'hidden',
      background: 'linear-gradient(135deg, #2b3a55 0%, #1a2238 50%, #4a3a5c 100%)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 16,
      padding: 20,
    }}>
      {/* faux wallpaper grain */}
      <div style={{
        position: 'absolute', inset: 0,
        background: 'radial-gradient(circle at 30% 20%, rgba(255,255,255,0.08), transparent 50%), radial-gradient(circle at 70% 80%, rgba(255,255,255,0.05), transparent 50%)',
      }} />
      <div style={{ position: 'relative', display: 'flex', gap: 14, alignItems: 'center' }}>{children}</div>
    </div>
  );
}

Object.assign(window, {
  WidgetSmall, WidgetMedium, WidgetLockCircular, WidgetLockRect, LockBg,
});
