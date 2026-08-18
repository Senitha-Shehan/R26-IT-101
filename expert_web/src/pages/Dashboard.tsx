import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { expertApi, DashboardStats, UncertainSample } from '../api/expertApi';
import { Loading } from '../components/Loading';
import { SampleCard } from '../components/SampleCard';
import { FileSearch, CheckCircle2, Layers, ArrowRight, RefreshCw, AlertCircle } from 'lucide-react';

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [recentSamples, setRecentSamples] = useState<UncertainSample[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  const fetchDashboardData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [statsData, pendingData] = await Promise.all([
        expertApi.getDashboardStats(),
        expertApi.getPendingSamples({ page: 1, limit: 6 }),
      ]);
      setStats(statsData);
      setRecentSamples(pendingData.items || []);
    } catch (err: any) {
      setError(err.message || 'Failed to load dashboard metrics.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboardData();
  }, []);

  if (loading) {
    return <Loading message="Loading expert portal dashboard statistics..." />;
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      {/* Header section */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#f8fafc' }}>
            CropGuard Expert Portal
          </h1>
          <p style={{ fontSize: '0.9rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
            Active Learning ground-truth review overview &amp; recent pending samples
          </p>
        </div>

        <button onClick={fetchDashboardData} className="btn-secondary" style={{ padding: '0.55rem 1rem' }}>
          <RefreshCw size={16} />
          <span>Refresh Data</span>
        </button>
      </div>

      {error && (
        <div
          style={{
            backgroundColor: 'rgba(244, 63, 94, 0.12)',
            border: '1px solid rgba(244, 63, 94, 0.3)',
            borderRadius: 'var(--radius-sm)',
            padding: '1rem',
            color: '#fda4af',
            display: 'flex',
            alignItems: 'center',
            gap: '0.75rem',
          }}
        >
          <AlertCircle size={20} color="#f43f5e" />
          <span>{error}</span>
        </div>
      )}

      {/* Summary Cards Grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: '1.5rem',
        }}
      >
        {/* Pending Card */}
        <div
          className="glass-card"
          style={{
            padding: '1.75rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            borderLeft: '4px solid #f59e0b',
          }}
        >
          <div>
            <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)', fontWeight: 500 }}>
              Pending Review
            </span>
            <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#f8fafc', margin: '0.2rem 0' }}>
              {stats?.pending_review ?? 0}
            </div>
            <span style={{ fontSize: '0.775rem', color: '#fbbf24', fontWeight: 500 }}>
              Awaiting expert ground-truth label
            </span>
          </div>
          <div
            style={{
              width: '56px',
              height: '56px',
              borderRadius: '14px',
              backgroundColor: 'rgba(245, 158, 11, 0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <FileSearch size={28} color="#f59e0b" />
          </div>
        </div>

        {/* Reviewed Card */}
        <div
          className="glass-card"
          style={{
            padding: '1.75rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            borderLeft: '4px solid #10b981',
          }}
        >
          <div>
            <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)', fontWeight: 500 }}>
              Reviewed
            </span>
            <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#f8fafc', margin: '0.2rem 0' }}>
              {stats?.reviewed ?? 0}
            </div>
            <span style={{ fontSize: '0.775rem', color: '#34d399', fontWeight: 500 }}>
              Verified expert ground-truth labels
            </span>
          </div>
          <div
            style={{
              width: '56px',
              height: '56px',
              borderRadius: '14px',
              backgroundColor: 'rgba(16, 185, 129, 0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <CheckCircle2 size={28} color="#10b981" />
          </div>
        </div>

        {/* Total Card */}
        <div
          className="glass-card"
          style={{
            padding: '1.75rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            borderLeft: '4px solid #3b82f6',
          }}
        >
          <div>
            <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)', fontWeight: 500 }}>
              Total Samples
            </span>
            <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#f8fafc', margin: '0.2rem 0' }}>
              {stats?.total ?? 0}
            </div>
            <span style={{ fontSize: '0.775rem', color: '#60a5fa', fontWeight: 500 }}>
              Uploaded from Flutter mobile queue
            </span>
          </div>
          <div
            style={{
              width: '56px',
              height: '56px',
              borderRadius: '14px',
              backgroundColor: 'rgba(59, 130, 246, 0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Layers size={28} color="#3b82f6" />
          </div>
        </div>
      </div>

      {/* Recent Pending Samples Section */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h2 style={{ fontSize: '1.25rem', fontWeight: 600, color: '#f8fafc' }}>
              Recent Uncertain Samples
            </h2>
            <span style={{ fontSize: '0.825rem', color: 'var(--text-muted)' }}>
              Low-confidence prediction samples (&lt; 0.80) synced from Edge AI
            </span>
          </div>

          <button onClick={() => navigate('/samples')} className="btn-secondary" style={{ padding: '0.5rem 0.85rem', fontSize: '0.85rem' }}>
            <span>View All Pending</span>
            <ArrowRight size={16} />
          </button>
        </div>

        {recentSamples.length === 0 ? (
          <div className="glass-card" style={{ padding: '3rem', textAlign: 'center', color: 'var(--text-muted)' }}>
            <FileSearch size={40} color="var(--text-subtle)" style={{ marginBottom: '0.75rem' }} />
            <p style={{ fontWeight: 600, color: '#f8fafc' }}>No Pending Samples</p>
            <span style={{ fontSize: '0.85rem' }}>All uploaded uncertain samples have been reviewed!</span>
          </div>
        ) : (
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
              gap: '1.25rem',
            }}
          >
            {recentSamples.map((sample) => (
              <SampleCard key={sample.sample_id || sample.id} sample={sample} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
