import React, { useState, useEffect } from 'react';

const FRAMES = [
  '/photos/LK/Loading3D.svg',
  '/photos/LK/Loading3DReverse.svg',
];

const STRIP_NORMAL = [0, 1, 0];
const STRIP_REVERSE = [1, 0, 1];

const FRAME_INTERVAL_MS = 320;
const EASING = 'cubic-bezier(0.4, 0, 0.2, 1)';

// Loading3D.svg viewBox 37×14
const ASPECT_RATIO = '37/14';

// Зоны: normal слева 70%, reverse справа 70% — пересечение только по центру
const ZONE_WIDTH = '70%';

function StripLayer({ stripIndices, useTransition, step, alt = '', isFirstLayer }) {
  const translateX = -step * (100 / 3);
  return (
    <div
      className="absolute inset-0 flex"
      style={{
        transition: useTransition ? `transform ${FRAME_INTERVAL_MS}ms ${EASING}` : 'none',
        transform: `translateX(${translateX}%)`,
      }}
    >
      {stripIndices.map((frameIdx, i) => (
        <div key={i} className="flex-shrink-0 w-1/3 h-full flex items-center justify-center">
          <img
            src={FRAMES[frameIdx]}
            alt={isFirstLayer && i === 0 ? alt : ''}
            aria-hidden={!(isFirstLayer && i === 0)}
            className="w-full h-full object-contain pointer-events-none"
          />
        </div>
      ))}
    </div>
  );
}

export function Krutilka3dSpinner({ className = 'w-48', alt = '' }) {
  const [step, setStep] = useState(0);
  const [useTransition, setUseTransition] = useState(true);

  useEffect(() => {
    const id = setInterval(() => {
      setStep((s) => {
        if (s < 2) return s + 1;
        setUseTransition(false);
        return 0;
      });
    }, FRAME_INTERVAL_MS);
    return () => clearInterval(id);
  }, []);

  useEffect(() => {
    if (useTransition) return;
    const t = requestAnimationFrame(() => {
      requestAnimationFrame(() => setUseTransition(true));
    });
    return () => cancelAnimationFrame(t);
  }, [useTransition]);

  return (
    <div
      className={`relative overflow-hidden ${className}`}
      style={{ aspectRatio: ASPECT_RATIO }}
    >
      {/* Левая зона: только normal */}
      <div
        className="absolute left-0 top-0 bottom-0 overflow-hidden"
        style={{ width: ZONE_WIDTH }}
      >
        <div className="absolute left-0 top-0 bottom-0 w-[300%]">
          <StripLayer
            stripIndices={STRIP_NORMAL}
            useTransition={useTransition}
            step={step}
            alt={alt}
            isFirstLayer
          />
        </div>
      </div>
      {/* Правая зона: только reverse, пересекается с левой по центру */}
      <div
        className="absolute right-0 top-0 bottom-0 overflow-hidden"
        style={{ width: ZONE_WIDTH }}
      >
        <div className="absolute left-0 top-0 bottom-0 w-[300%]">
          <StripLayer
            stripIndices={STRIP_REVERSE}
            useTransition={useTransition}
            step={step}
          />
        </div>
      </div>
    </div>
  );
}
