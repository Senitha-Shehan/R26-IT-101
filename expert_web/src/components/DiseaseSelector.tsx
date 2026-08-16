import React, { useState, useEffect } from 'react';
import { expertApi } from '../api/expertApi';
import { CheckCircle } from 'lucide-react';

interface DiseaseSelectorProps {
  value: string;
  onChange: (selectedDisease: string) => void;
  disabled?: boolean;
}

const DEFAULT_CLASSES = [
  "Bacterial Leaf Blight",
  "Brown Spot",
  "Healthy Rice Leaf",
  "Leaf Blast",
  "Leaf Scald",
  "Narrow Brown Leaf Spot",
  "Rice Hispa",
  "Sheath Blight"
];

export const DiseaseSelector: React.FC<DiseaseSelectorProps> = ({ value, onChange, disabled = false }) => {
  const [classes, setClasses] = useState<string[]>(DEFAULT_CLASSES);

  useEffect(() => {
    expertApi.getDiseaseClasses()
      .then((data) => {
        if (data && data.length > 0) {
          setClasses(data);
        }
      })
      .catch(() => {
        // Fallback to default 8 classes
      });
  }, []);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
      <label style={{ fontSize: '0.875rem', fontWeight: 600, color: 'var(--text-main)' }}>
        Expert Diagnosis (Ground-Truth Disease Label) <span style={{ color: 'var(--accent-rose)' }}>*</span>
      </label>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        disabled={disabled}
        style={{
          width: '100%',
          padding: '0.8rem 1rem',
          fontSize: '0.95rem',
          fontWeight: 500,
          backgroundColor: 'var(--bg-input)',
          color: '#ffffff',
          border: value ? '1px solid var(--primary)' : '1px solid var(--border-color)',
          borderRadius: 'var(--radius-sm)',
          cursor: disabled ? 'not-allowed' : 'pointer',
        }}
      >
        <option value="" disabled>
          -- Select Ground-Truth Disease Class --
        </option>
        {classes.map((cls) => (
          <option key={cls} value={cls} style={{ backgroundColor: '#0f172a', color: '#f8fafc' }}>
            {cls}
          </option>
        ))}
      </select>
      {value && (
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', color: '#34d399', fontSize: '0.8rem', marginTop: '0.15rem' }}>
          <CheckCircle size={14} /> Selected: <strong>{value}</strong>
        </div>
      )}
    </div>
  );
};
