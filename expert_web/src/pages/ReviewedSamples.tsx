import React, { useState, useEffect } from 'react';
import { expertApi, UncertainSample, PaginatedResponse } from '../api/expertApi';
import { Loading } from '../components/Loading';
import { SampleTable } from '../components/SampleTable';
import { SampleCard } from '../components/SampleCard';
import { Filter, CheckCircle2, LayoutGrid, List, ChevronLeft, ChevronRight, RefreshCw } from 'lucide-react';

const REGIONS = [
  { value: '', label: 'All Regions' },
  { value: 'central_highlands', label: 'Central Highlands' },
  { value: 'dry_zone', label: 'Dry Zone' },
  { value: 'wet_zone', label: 'Wet Zone' },
  { value: 'intermediate_zone', label: 'Intermediate Zone' },
  { value: 'northern_region', label: 'Northern Region' },
  { value: 'southern_coastal', label: 'Southern Coastal' },
  { value: 'eastern_province', label: 'Eastern Province' },
  { value: 'north_central', label: 'North Central' },
  { value: 'north_western', label: 'North Western' },
];

export const ReviewedSamples: React.FC = () => {
  const [data, setData] = useState<PaginatedResponse<UncertainSample> | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [page, setPage] = useState<number>(1);
  const [region, setRegion] = useState<string>('');
  const [expertDisease, setExpertDisease] = useState<string>('');
  const [viewMode, setViewMode] = useState<'table' | 'grid'>('table');

  const fetchReviewed = async () => {
    setLoading(true);
    try {
      const res = await expertApi.getReviewedSamples({
        page,
        limit: 10,
        region: region || undefined,
        expert_disease: expertDisease || undefined,
      });
      setData(res);
    } catch {
      // Handled
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReviewed();
  }, [page, region, expertDisease]);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.75rem' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#f8fafc' }}>
            Reviewed Samples History
          </h1>
          <p style={{ fontSize: '0.875rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
            Verified ground-truth expert annotations &amp; research data archive
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <div
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.05)',
              border: '1px solid var(--border-color)',
              borderRadius: 'var(--radius-sm)',
              display: 'flex',
              padding: '2px',
            }}
          >
            <button
              onClick={() => setViewMode('table')}
              style={{
                backgroundColor: viewMode === 'table' ? 'rgba(16, 185, 129, 0.2)' : 'transparent',
                color: viewMode === 'table' ? '#10b981' : 'var(--text-muted)',
                padding: '0.45rem 0.75rem',
                borderRadius: '6px',
                display: 'flex',
                alignItems: 'center',
                gap: '0.35rem',
                fontSize: '0.825rem',
              }}
            >
              <List size={16} />
              <span>Table</span>
            </button>
            <button
              onClick={() => setViewMode('grid')}
              style={{
                backgroundColor: viewMode === 'grid' ? 'rgba(16, 185, 129, 0.2)' : 'transparent',
                color: viewMode === 'grid' ? '#10b981' : 'var(--text-muted)',
                padding: '0.45rem 0.75rem',
                borderRadius: '6px',
                display: 'flex',
                alignItems: 'center',
                gap: '0.35rem',
                fontSize: '0.825rem',
              }}
            >
              <LayoutGrid size={16} />
              <span>Grid</span>
            </button>
          </div>

          <button onClick={fetchReviewed} className="btn-secondary" style={{ padding: '0.55rem 0.85rem' }}>
            <RefreshCw size={16} />
          </button>
        </div>
      </div>

      {/* Filter Bar */}
      <div
        className="glass-card"
        style={{
          padding: '1.25rem',
          display: 'flex',
          flexWrap: 'wrap',
          alignItems: 'center',
          gap: '1rem',
          backgroundColor: 'rgba(15, 23, 42, 0.7)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--text-muted)', fontSize: '0.875rem', fontWeight: 600 }}>
          <Filter size={18} color="#3b82f6" />
          <span>Filters:</span>
        </div>

        <select
          value={region}
          onChange={(e) => {
            setRegion(e.target.value);
            setPage(1);
          }}
          style={{ minWidth: '180px' }}
        >
          {REGIONS.map((r) => (
            <option key={r.value} value={r.value}>
              {r.label}
            </option>
          ))}
        </select>

        {(region || expertDisease) && (
          <button
            onClick={() => {
              setRegion('');
              setExpertDisease('');
              setPage(1);
            }}
            style={{
              background: 'none',
              color: 'var(--accent-rose)',
              fontSize: '0.825rem',
              fontWeight: 600,
              padding: '0.4rem 0.75rem',
            }}
          >
            Clear Filters
          </button>
        )}

        <div style={{ marginLeft: 'auto', fontSize: '0.85rem', color: 'var(--text-subtle)' }}>
          Total Reviewed: <strong>{data?.total || 0}</strong> samples
        </div>
      </div>

      {/* Content */}
      {loading ? (
        <Loading message="Fetching reviewed ground-truth archive..." />
      ) : viewMode === 'table' ? (
        <SampleTable samples={data?.items || []} showExpertLabel={true} />
      ) : data?.items && data.items.length > 0 ? (
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))',
            gap: '1.5rem',
          }}
        >
          {data.items.map((sample) => (
            <SampleCard key={sample.sample_id || sample.id} sample={sample} />
          ))}
        </div>
      ) : (
        <div className="glass-card" style={{ padding: '3rem', textAlign: 'center', color: 'var(--text-muted)' }}>
          <CheckCircle2 size={48} color="var(--text-subtle)" style={{ marginBottom: '1rem' }} />
          <p style={{ fontSize: '1.1rem', fontWeight: 600, color: '#f8fafc' }}>No Reviewed Samples Found</p>
          <span style={{ fontSize: '0.85rem' }}>No samples have been annotated under the active filter parameters.</span>
        </div>
      )}

      {/* Pagination */}
      {data && data.pages > 1 && (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '1rem', marginTop: '1rem' }}>
          <button
            onClick={() => setPage((p) => Math.max(p - 1, 1))}
            disabled={page === 1}
            className="btn-secondary"
            style={{ padding: '0.5rem 0.85rem' }}
          >
            <ChevronLeft size={16} />
            <span>Previous</span>
          </button>

          <span style={{ fontSize: '0.875rem', color: 'var(--text-muted)' }}>
            Page <strong>{page}</strong> of <strong>{data.pages}</strong>
          </span>

          <button
            onClick={() => setPage((p) => Math.min(p + 1, data.pages))}
            disabled={page === data.pages}
            className="btn-secondary"
            style={{ padding: '0.5rem 0.85rem' }}
          >
            <span>Next</span>
            <ChevronRight size={16} />
          </button>
        </div>
      )}
    </div>
  );
};
