import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { UncertainSample, expertApi } from '../api/expertApi';
import { ArrowRight, CheckCircle, MapPin, FileText } from 'lucide-react';

interface SampleTableProps {
  samples: UncertainSample[];
  showExpertLabel?: boolean;
}

const TableRowImage: React.FC<{ sampleId: string; altText: string }> = ({ sampleId, altText }) => {
  const [imageUrl, setImageUrl] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    expertApi.getSampleImageUrl(sampleId)
      .then((url) => {
        if (active) setImageUrl(url);
      })
      .catch(() => {});

    return () => {
      active = false;
      if (imageUrl && imageUrl.startsWith('blob:')) {
        URL.revokeObjectURL(imageUrl);
      }
    };
  }, [sampleId]);

  return (
    <div
      style={{
        width: '54px',
        height: '54px',
        borderRadius: '8px',
        backgroundColor: 'rgba(15, 23, 42, 0.9)',
        overflow: 'hidden',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        border: '1px solid var(--border-color)',
      }}
    >
      {imageUrl ? (
        <img src={imageUrl} alt={altText} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      ) : (
        <FileText size={20} color="var(--text-subtle)" />
      )}
    </div>
  );
};

export const SampleTable: React.FC<SampleTableProps> = ({ samples, showExpertLabel = false }) => {
  const navigate = useNavigate();

  if (!samples || samples.length === 0) {
    return (
      <div className="glass-card" style={{ padding: '3rem', textAlign: 'center', color: 'var(--text-muted)' }}>
        <FileText size={48} color="var(--text-subtle)" style={{ marginBottom: '1rem' }} />
        <p style={{ fontSize: '1.1rem', fontWeight: 600, color: '#f8fafc' }}>No uncertain samples found</p>
        <span style={{ fontSize: '0.85rem' }}>No records match the active filter criteria.</span>
      </div>
    );
  }

  return (
    <div className="glass-card" style={{ overflowX: 'auto' }}>
      <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.9rem' }}>
        <thead>
          <tr
            style={{
              borderBottom: '1px solid var(--border-color)',
              backgroundColor: 'rgba(15, 23, 42, 0.6)',
              color: 'var(--text-muted)',
              fontSize: '0.8rem',
              textTransform: 'uppercase',
              letterSpacing: '0.05em',
            }}
          >
            <th style={{ padding: '1rem' }}>Image</th>
            <th style={{ padding: '1rem' }}>Sample ID</th>
            <th style={{ padding: '1rem' }}>AI Prediction</th>
            <th style={{ padding: '1rem' }}>Confidence</th>
            {showExpertLabel && <th style={{ padding: '1rem' }}>Expert Label</th>}
            <th style={{ padding: '1rem' }}>Region</th>
            <th style={{ padding: '1rem' }}>Date</th>
            <th style={{ padding: '1rem' }}>Status</th>
            <th style={{ padding: '1rem', textAlign: 'right' }}>Action</th>
          </tr>
        </thead>
        <tbody>
          {samples.map((sample) => {
            const isReviewed = sample.status === 'reviewed' || sample.status === 'annotated';
            const dateStr = sample.created_at
              ? new Date(sample.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
              : 'Unknown';

            return (
              <tr
                key={sample.sample_id || sample.id}
                style={{
                  borderBottom: '1px solid var(--border-color)',
                  transition: 'background-color 0.15s ease',
                }}
                onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'rgba(255, 255, 255, 0.03)')}
                onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'transparent')}
              >
                <td style={{ padding: '0.75rem 1rem' }}>
                  <TableRowImage sampleId={sample.sample_id} altText={sample.predicted_disease} />
                </td>
                <td style={{ padding: '1rem', fontWeight: 600, color: '#f8fafc', fontFamily: 'monospace', fontSize: '0.85rem' }}>
                  {sample.sample_id.length > 14 ? `${sample.sample_id.substring(0, 14)}...` : sample.sample_id}
                </td>
                <td style={{ padding: '1rem', fontWeight: 600, color: '#f8fafc' }}>
                  {sample.predicted_disease}
                </td>
                <td style={{ padding: '1rem' }}>
                  <span
                    style={{
                      fontWeight: 700,
                      color: sample.confidence < 0.8 ? '#f59e0b' : '#10b981',
                    }}
                  >
                    {(sample.confidence * 100).toFixed(2)}%
                  </span>
                </td>
                {showExpertLabel && (
                  <td style={{ padding: '1rem', fontWeight: 600, color: '#34d399' }}>
                    {sample.expert_label || '—'}
                  </td>
                )}
                <td style={{ padding: '1rem' }}>
                  <span className="badge badge-region">
                    <MapPin size={10} style={{ marginRight: '3px' }} />
                    {sample.region.replace('_', ' ')}
                  </span>
                </td>
                <td style={{ padding: '1rem', color: 'var(--text-muted)', fontSize: '0.825rem' }}>
                  {dateStr}
                </td>
                <td style={{ padding: '1rem' }}>
                  <span className={isReviewed ? 'badge badge-reviewed' : 'badge badge-pending'}>
                    {isReviewed ? 'Reviewed' : 'Pending Review'}
                  </span>
                </td>
                <td style={{ padding: '1rem', textAlign: 'right' }}>
                  <button
                    onClick={() => navigate(`/samples/${sample.sample_id}`)}
                    className="btn-secondary"
                    style={{ padding: '0.45rem 0.85rem', fontSize: '0.8rem', borderRadius: '6px' }}
                  >
                    <span>{isReviewed ? 'View' : 'Review'}</span>
                    <ArrowRight size={14} />
                  </button>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
};
