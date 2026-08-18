import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { expertApi, UncertainSample } from '../api/expertApi';
import { Loading } from '../components/Loading';
import { ImageViewer } from '../components/ImageViewer';
import { DiseaseSelector } from '../components/DiseaseSelector';
import { 
  ArrowLeft, 
  CheckCircle, 
  AlertTriangle, 
  Cpu, 
  MapPin, 
  Calendar, 
  FileText, 
  Send,
  ShieldCheck
} from 'lucide-react';

export const ReviewSample: React.FC = () => {
  const { sampleId } = useParams<{ sampleId: string }>();
  const navigate = useNavigate();

  const [sample, setSample] = useState<UncertainSample | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const [expertLabel, setExpertLabel] = useState<string>('');
  const [expertNotes, setExpertNotes] = useState<string>('');
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const fetchDetail = async () => {
    if (!sampleId) return;
    setLoading(true);
    setError(null);
    try {
      const data = await expertApi.getSampleDetail(sampleId);
      setSample(data);
      if (data.expert_label) {
        setExpertLabel(data.expert_label);
      }
      if (data.expert_notes) {
        setExpertNotes(data.expert_notes);
      }
    } catch (err: any) {
      setError(err.message || 'Failed to retrieve sample details.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDetail();
  }, [sampleId]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!sampleId || !sample) return;

    if (!expertLabel) {
      setError('Please select a valid ground-truth disease class.');
      return;
    }

    setSubmitting(true);
    setError(null);
    setSuccessMessage(null);

    try {
      const res = await expertApi.submitReview({
        sample_id: sampleId,
        expert_label: expertLabel,
        expert_notes: expertNotes,
      });

      setSuccessMessage(res.message || 'Expert label submitted successfully.');
      if (res.sample) {
        setSample(res.sample);
      }
    } catch (err: any) {
      if (err.status === 409) {
        setError('This sample has already been reviewed.');
      } else {
        setError(err.message || 'Failed to submit expert review.');
      }
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return <Loading message="Loading sample inspection details..." />;
  }

  if (error && !sample) {
    return (
      <div className="glass-card" style={{ padding: '3rem', textAlign: 'center' }}>
        <AlertTriangle size={48} color="var(--accent-rose)" style={{ marginBottom: '1rem' }} />
        <h2 style={{ color: 'var(--accent-rose)' }}>Sample Not Found</h2>
        <p style={{ color: 'var(--text-muted)', margin: '0.5rem 0 1.5rem 0' }}>{error}</p>
        <button onClick={() => navigate('/samples')} className="btn-secondary">
          <ArrowLeft size={16} />
          <span>Back to Pending Samples</span>
        </button>
      </div>
    );
  }

  if (!sample) return null;

  const isReviewed = sample.status === 'reviewed' || sample.status === 'annotated';
  const confidencePct = (sample.confidence * 100).toFixed(2);
  const createdDate = sample.created_at
    ? new Date(sample.created_at).toLocaleString()
    : 'Unknown';

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
      {/* Top Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <button onClick={() => navigate(-1)} className="btn-secondary" style={{ padding: '0.5rem 1rem' }}>
          <ArrowLeft size={16} />
          <span>Back</span>
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
            Sample ID: <code style={{ color: '#f8fafc', fontWeight: 600 }}>{sample.sample_id}</code>
          </span>
          <span className={isReviewed ? 'badge badge-reviewed' : 'badge badge-pending'}>
            {isReviewed ? 'Reviewed' : 'Pending Review'}
          </span>
        </div>
      </div>

      {/* Success Notification Alert */}
      {successMessage && (
        <div
          style={{
            backgroundColor: 'rgba(16, 185, 129, 0.15)',
            border: '1px solid rgba(16, 185, 129, 0.4)',
            borderRadius: 'var(--radius-sm)',
            padding: '1rem 1.25rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            color: '#34d399',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <CheckCircle size={22} color="#10b981" />
            <span style={{ fontWeight: 600, fontSize: '0.95rem' }}>{successMessage}</span>
          </div>
          <button onClick={() => navigate('/samples')} className="btn-primary" style={{ padding: '0.45rem 0.85rem', fontSize: '0.825rem' }}>
            <span>Next Sample</span>
          </button>
        </div>
      )}

      {/* Error Alert */}
      {error && (
        <div
          style={{
            backgroundColor: 'rgba(244, 63, 94, 0.15)',
            border: '1px solid rgba(244, 63, 94, 0.35)',
            borderRadius: 'var(--radius-sm)',
            padding: '1rem 1.25rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.75rem',
            color: '#fda4af',
          }}
        >
          <AlertTriangle size={20} color="#f43f5e" />
          <span>{error}</span>
        </div>
      )}

      {/* Main Two-Column Layout */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(360px, 1fr))',
          gap: '1.75rem',
          alignItems: 'start',
        }}
      >
        {/* LEFT COLUMN: Image Inspection */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <h2 style={{ fontSize: '1.1rem', fontWeight: 600, color: '#f8fafc' }}>
            Rice Leaf Image Inspection
          </h2>
          <ImageViewer
            imageUrlFetcher={() => expertApi.getSampleImageUrl(sample.sample_id)}
            altText={sample.predicted_disease}
          />
        </div>

        {/* RIGHT COLUMN: AI Metadata + Expert Form */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
          {/* AI Metadata Box */}
          <div className="glass-card" style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#10b981', borderBottom: '1px solid var(--border-color)', paddingBottom: '0.75rem' }}>
              <Cpu size={20} />
              <h3 style={{ fontSize: '1.05rem', fontWeight: 600, color: '#f8fafc' }}>
                AI Prediction Details (Preserved)
              </h3>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div>
                <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', textTransform: 'uppercase' }}>AI Predicted Disease</span>
                <p style={{ fontSize: '1.1rem', fontWeight: 700, color: '#f8fafc', marginTop: '0.1rem' }}>
                  {sample.predicted_disease}
                </p>
              </div>

              <div>
                <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', textTransform: 'uppercase' }}>AI Confidence</span>
                <p style={{ fontSize: '1.1rem', fontWeight: 700, color: sample.confidence < 0.8 ? '#f59e0b' : '#10b981', marginTop: '0.1rem' }}>
                  {confidencePct}%
                </p>
              </div>

              <div>
                <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', textTransform: 'uppercase' }}>Agricultural Region</span>
                <p style={{ fontSize: '0.9rem', color: 'var(--text-muted)', fontWeight: 500, marginTop: '0.1rem' }}>
                  {sample.region.replace('_', ' ')}
                </p>
              </div>

              <div>
                <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', textTransform: 'uppercase' }}>TFLite Model</span>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', fontFamily: 'monospace', marginTop: '0.1rem' }}>
                  {sample.model_id}
                </p>
              </div>
            </div>

            <div style={{ fontSize: '0.775rem', color: 'var(--text-subtle)', paddingTop: '0.5rem', borderTop: '1px solid var(--border-color)' }}>
              Detection Timestamp: {createdDate}
            </div>
          </div>

          {/* Expert Ground-Truth Form */}
          <div className="glass-card" style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#3b82f6', borderBottom: '1px solid var(--border-color)', paddingBottom: '0.75rem' }}>
              <ShieldCheck size={20} />
              <h3 style={{ fontSize: '1.05rem', fontWeight: 600, color: '#f8fafc' }}>
                Expert Ground-Truth Annotation
              </h3>
            </div>

            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
              {/* Disease Dropdown */}
              <DiseaseSelector
                value={expertLabel}
                onChange={setExpertLabel}
                disabled={isReviewed || submitting}
              />

              {/* Expert Notes Area */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem' }}>
                <label style={{ fontSize: '0.875rem', fontWeight: 600, color: 'var(--text-main)' }}>
                  Expert Clinical Notes (Optional)
                </label>
                <textarea
                  rows={4}
                  placeholder="Enter detailed diagnostic observations, symptom rationale, or discrepancy notes..."
                  value={expertNotes}
                  onChange={(e) => setExpertNotes(e.target.value)}
                  disabled={isReviewed || submitting}
                  style={{ width: '100%', resize: 'vertical' }}
                />
              </div>

              {/* Metadata display if reviewed */}
              {isReviewed && sample.reviewed_by && (
                <div style={{ backgroundColor: 'rgba(59, 130, 246, 0.1)', padding: '0.75rem 1rem', borderRadius: 'var(--radius-sm)', fontSize: '0.825rem', color: '#93c5fd' }}>
                  Reviewed by <strong>{sample.reviewed_by}</strong> on {sample.reviewed_at ? new Date(sample.reviewed_at).toLocaleString() : 'N/A'}
                </div>
              )}

              {/* Action Buttons */}
              <div style={{ display: 'flex', gap: '1rem', marginTop: '0.5rem' }}>
                {!isReviewed ? (
                  <button
                    type="submit"
                    className="btn-primary"
                    disabled={submitting || !expertLabel}
                    style={{ flex: 1, padding: '0.8rem', fontSize: '0.95rem' }}
                  >
                    {submitting ? (
                      <span>Saving Review...</span>
                    ) : (
                      <>
                        <Send size={18} />
                        <span>Submit Expert Label</span>
                      </>
                    )}
                  </button>
                ) : (
                  <div style={{ width: '100%', textAlign: 'center', color: '#34d399', fontWeight: 600, padding: '0.75rem', border: '1px solid rgba(16, 185, 129, 0.3)', borderRadius: 'var(--radius-sm)' }}>
                    ✓ Review Completed &amp; Locked
                  </div>
                )}
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};
