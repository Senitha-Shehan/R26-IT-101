import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { UncertainSample, expertApi } from '../api/expertApi';
import { ArrowRight, AlertTriangle, CheckCircle, MapPin, Cpu, Calendar } from 'lucide-react';

interface SampleCardProps {
  sample: UncertainSample;
}

export const SampleCard: React.FC<SampleCardProps> = ({ sample }) => {
  const navigate = useNavigate();
  const [thumbUrl, setThumbUrl] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    expertApi.getSampleImageUrl(sample.sample_id)
      .then((url) => {
        if (active) setThumbUrl(url);
      })
      .catch(() => {
        // Thumbnail load error fallback
      });

    return () => {
      active = false;
      if (thumbUrl && thumbUrl.startsWith('blob:')) {
        URL.revokeObjectURL(thumbUrl);
      }
    };
  }, [sample.sample_id]);

  const confidencePct = (sample.confidence * 100).toFixed(2);
  const isReviewed = sample.status === 'reviewed' || sample.status === 'annotated';

  return (
    <div
      className="glass-card"
      style={{
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        transition: 'transform 0.2s ease, box-shadow 0.2s ease',
        cursor: 'pointer',
      }}
      onClick={() => navigate(`/samples/${sample.sample_id}`)}
      onMouseEnter={(e) => {
        e.currentTarget.style.transform = 'translateY(-4px)';
        e.currentTarget.style.boxShadow = '0 12px 30px rgba(0, 0, 0, 0.6)';
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = 'translateY(0)';
        e.currentTarget.style.boxShadow = 'var(--shadow-card)';
      }}
    >
      {/* Thumbnail area */}
      <div
        style={{
          height: '180px',
          width: '100%',
          backgroundColor: 'rgba(15, 23, 42, 0.9)',
          position: 'relative',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          overflow: 'hidden',
        }}
      >
        {thumbUrl ? (
          <img
            src={thumbUrl}
            alt={sample.predicted_disease}
            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
          />
        ) : (
          <div style={{ color: 'var(--text-subtle)', fontSize: '0.85rem' }}>Leaf Image</div>
        )}

        <div style={{ position: 'absolute', top: '0.75rem', left: '0.75rem' }}>
          <span className={isReviewed ? 'badge badge-reviewed' : 'badge badge-pending'}>
            {isReviewed ? 'Reviewed' : 'Pending Review'}
          </span>
        </div>

        <div style={{ position: 'absolute', bottom: '0.75rem', right: '0.75rem' }}>
          <span className="badge badge-region">
            <MapPin size={10} style={{ marginRight: '3px' }} />
            {sample.region.replace('_', ' ')}
          </span>
        </div>
      </div>

      {/* Card Body */}
      <div style={{ padding: '1.25rem', display: 'flex', flexDirection: 'column', gap: '0.75rem', flex: 1 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <span style={{ fontSize: '0.725rem', color: 'var(--text-subtle)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              AI Prediction
            </span>
            <h3 style={{ fontSize: '1.05rem', fontWeight: 600, color: '#f8fafc', marginTop: '0.1rem' }}>
              {sample.predicted_disease}
            </h3>
          </div>
          <div style={{ textAlign: 'right' }}>
            <span style={{ fontSize: '0.725rem', color: 'var(--text-subtle)' }}>Confidence</span>
            <div style={{ fontSize: '0.95rem', fontWeight: 700, color: sample.confidence < 0.8 ? '#f59e0b' : '#10b981' }}>
              {confidencePct}%
            </div>
          </div>
        </div>

        {isReviewed && sample.expert_label && (
          <div
            style={{
              backgroundColor: 'rgba(16, 185, 129, 0.1)',
              border: '1px solid rgba(16, 185, 129, 0.25)',
              borderRadius: 'var(--radius-sm)',
              padding: '0.5rem 0.75rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
            }}
          >
            <CheckCircle size={16} color="#34d399" />
            <div>
              <span style={{ fontSize: '0.7rem', color: 'var(--text-muted)', display: 'block' }}>Expert Label:</span>
              <span style={{ fontSize: '0.85rem', fontWeight: 600, color: '#34d399' }}>{sample.expert_label}</span>
            </div>
          </div>
        )}

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 'auto', paddingTop: '0.75rem', borderTop: '1px solid var(--border-color)', fontSize: '0.775rem', color: 'var(--text-muted)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
            <Cpu size={14} color="var(--text-subtle)" />
            <span style={{ maxWidth: '110px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {sample.model_id}
            </span>
          </div>
          <button
            onClick={(e) => {
              e.stopPropagation();
              navigate(`/samples/${sample.sample_id}`);
            }}
            className="btn-primary"
            style={{ padding: '0.4rem 0.85rem', fontSize: '0.8rem', borderRadius: '6px' }}
          >
            <span>{isReviewed ? 'View Details' : 'Review'}</span>
            <ArrowRight size={14} />
          </button>
        </div>
      </div>
    </div>
  );
};
