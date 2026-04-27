// wireframes.jsx — hand-drawn wireframe primitives for Quiet Kcal
// Sketchy vibe: rough strokes, handwritten type, placeholders

const INK = '#1a1a1a';
const PAPER = '#fbf9f4';
const MUTED = '#8a8680';
const WARN = '#c8422d';
const FADE = '#d8d4cc';

const HAND = '"Caveat", "Kalam", "Comic Sans MS", cursive';
const HAND_TIGHT = '"Kalam", "Caveat", cursive';
const MONO = '"JetBrains Mono", "IBM Plex Mono", monospace';

// ── Sketchy stroke helper: slightly wobbly rectangle via SVG path ──
function sketchyRect({ w, h, r = 8, stroke = INK, strokeWidth = 1.5, fill = 'none', dashed = false, seed = 1 }) {
  // jitter path
  const j = (n) => (Math.sin(seed * n * 12.9898) * 43758.5453) % 1;
  const wob = 0.6;
  const x1 = j(1) * wob, y1 = j(2) * wob;
  const x2 = w + j(3) * wob, y2 = j(4) * wob;
  const x3 = w + j(5) * wob, y3 = h + j(6) * wob;
  const x4 = j(7) * wob, y4 = h + j(8) * wob;
  const d = `M ${x1 + r} ${y1} L ${x2 - r} ${y2} Q ${x2} ${y2} ${x2} ${y2 + r} L ${x3} ${y3 - r} Q ${x3} ${y3} ${x3 - r} ${y3} L ${x4 + r} ${y4} Q ${x4} ${y4} ${x4} ${y4 - r} L ${x1} ${y1 + r} Q ${x1} ${y1} ${x1 + r} ${y1} Z`;
  return (
    <svg width={w + 4} height={h + 4} style={{ position: 'absolute', top: -2, left: -2, overflow: 'visible' }}>
      <path d={d} stroke={stroke} strokeWidth={strokeWidth} fill={fill}
        strokeDasharray={dashed ? '4 3' : undefined}
        strokeLinecap="round" strokeLinejoin="round"
        transform="translate(2,2)" />
    </svg>
  );
}

// A rough box with children inside
function SkBox({ children, w = '100%', h, r = 10, stroke = INK, sw = 1.4, fill = 'none', dashed = false, seed = 1, style = {} }) {
  const [size, setSize] = React.useState({ w: typeof w === 'number' ? w : 0, h: h || 0 });
  const ref = React.useRef(null);
  React.useLayoutEffect(() => {
    if (ref.current) {
      const b = ref.current.getBoundingClientRect();
      setSize({ w: b.width, h: b.height });
    }
  }, []);
  return (
    <div ref={ref} style={{ position: 'relative', width: w, height: h, boxSizing: 'border-box', ...style }}>
      {size.w > 0 && sketchyRect({ w: size.w, h: size.h, r, stroke, strokeWidth: sw, fill, dashed, seed })}
      <div style={{ position: 'relative', width: '100%', height: '100%', boxSizing: 'border-box' }}>{children}</div>
    </div>
  );
}

// Sketchy circle (for ring)
function SkCircle({ size, stroke = INK, sw = 2, fill = 'none', dashed = false, progress, progressColor = INK }) {
  const r = size / 2 - sw;
  const c = size / 2;
  const circ = 2 * Math.PI * r;
  return (
    <svg width={size} height={size} style={{ display: 'block' }}>
      <circle cx={c} cy={c} r={r} stroke={stroke} strokeWidth={sw} fill={fill}
        strokeDasharray={dashed ? '4 3' : undefined} />
      {progress !== undefined && (
        <circle cx={c} cy={c} r={r}
          stroke={progressColor} strokeWidth={sw + 1} fill="none"
          strokeDasharray={`${circ * progress} ${circ}`}
          strokeDashoffset={circ * 0.25}
          strokeLinecap="round"
          transform={`rotate(-90 ${c} ${c})`} />
      )}
    </svg>
  );
}

// Scribble lines (for text placeholder)
function SkScribble({ width = 80, lines = 1, sw = 1.2, color = MUTED, gap = 6 }) {
  return (
    <svg width={width} height={lines * gap + 2} style={{ display: 'block' }}>
      {Array.from({ length: lines }).map((_, i) => {
        const y = i * gap + 2;
        const w = width * (0.6 + (i % 3) * 0.15);
        return <line key={i} x1={2} y1={y} x2={w} y2={y} stroke={color} strokeWidth={sw} strokeLinecap="round" />;
      })}
    </svg>
  );
}

// Image/photo placeholder (striped)
let __skpCounter = 0;
function SkPlaceholder({ w, h, label, r = 8 }) {
  const id = React.useMemo(() => `skp-${++__skpCounter}`, []);
  return (
    <div style={{ position: 'relative', width: w, height: h }}>
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0, display: 'block' }}>
        <defs>
          <pattern id={id} patternUnits="userSpaceOnUse" width="8" height="8" patternTransform="rotate(-45)">
            <rect width="8" height="8" fill="transparent" />
            <line x1="0" y1="0" x2="0" y2="8" stroke={FADE} strokeWidth="1" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" rx={r} fill={`url(#${id})`} stroke={MUTED} strokeWidth="1" strokeDasharray="3 3" />
      </svg>
      {label && (
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: 0.5,
        }}>{label}</div>
      )}
    </div>
  );
}

// Annotation arrow
function SkArrow({ from, to, color = MUTED }) {
  const dx = to.x - from.x, dy = to.y - from.y;
  const len = Math.sqrt(dx * dx + dy * dy);
  const ang = Math.atan2(dy, dx);
  return (
    <svg style={{ position: 'absolute', inset: 0, pointerEvents: 'none', overflow: 'visible' }}>
      <path d={`M ${from.x} ${from.y} Q ${(from.x + to.x) / 2 + 20} ${(from.y + to.y) / 2 - 20} ${to.x} ${to.y}`}
        stroke={color} strokeWidth="1.2" fill="none" strokeLinecap="round" />
      <path d={`M ${to.x} ${to.y} L ${to.x - 8 * Math.cos(ang - 0.4)} ${to.y - 8 * Math.sin(ang - 0.4)} M ${to.x} ${to.y} L ${to.x - 8 * Math.cos(ang + 0.4)} ${to.y - 8 * Math.sin(ang + 0.4)}`}
        stroke={color} strokeWidth="1.2" fill="none" strokeLinecap="round" />
    </svg>
  );
}

// FAB placeholder
function SkFAB({ bottom = 30, right = 24 }) {
  return (
    <div style={{ position: 'absolute', bottom, right, width: 56, height: 56 }}>
      <SkCircle size={56} stroke={INK} sw={1.6} fill={PAPER} />
      <div style={{
        position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontFamily: HAND, fontSize: 32, color: INK, lineHeight: 1,
      }}>+</div>
    </div>
  );
}

// Handwritten text
function Hand({ children, size = 18, color = INK, weight = 400, style = {} }) {
  return <div style={{ fontFamily: HAND, fontSize: size, color, fontWeight: weight, lineHeight: 1.2, ...style }}>{children}</div>;
}

// Status bar placeholder (simplified sketch version)
function SketchyStatusBar() {
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '18px 32px 8px', fontFamily: HAND_TIGHT, fontSize: 14, color: INK,
    }}>
      <span>9:41</span>
      <span style={{ letterSpacing: 1 }}>··· ◐ ▬</span>
    </div>
  );
}

// Home indicator
function SketchyHomeBar() {
  return (
    <div style={{ position: 'absolute', bottom: 8, left: 0, right: 0, display: 'flex', justifyContent: 'center' }}>
      <div style={{ width: 130, height: 4, borderRadius: 2, background: INK, opacity: 0.4 }} />
    </div>
  );
}

Object.assign(window, {
  INK, PAPER, MUTED, WARN, FADE, HAND, HAND_TIGHT, MONO,
  SkBox, SkCircle, SkScribble, SkPlaceholder, SkArrow, SkFAB, Hand,
  SketchyStatusBar, SketchyHomeBar, sketchyRect,
});
