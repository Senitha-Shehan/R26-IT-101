import React, { useState, useEffect } from 'react';
import { expertApi, UncertainSample, PaginatedResponse } from '../api/expertApi';
import { Loading } from '../components/Loading';
import { SampleCard } from '../components/SampleCard';
import { SampleTable } from '../components/SampleTable';
import { Filter, LayoutGrid, List, ChevronLeft, ChevronRight, RefreshCw } from 'lucide-react';

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

const DISEASES = [
  { value: '', label: 'All AI Predictions' },
  { value: 'Bacterial Leaf Blight', label: 'Bacterial Leaf Blight' },
  { value: 'Brown Spot', label: 'Brown Spot' },
  { value: 'Healthy Rice Leaf', label: 'Healthy Rice Leaf' },
  { value: 'Leaf Blast', label: 'Leaf Blast' },
  { value: 'Leaf Scald', label: 'Leaf Scald' },
  { value: 'Narrow Brown Leaf Spot', label: 'Narrow Brown Leaf Spot' },
  { value: 'Rice Hispa', label: 'Rice Hispa' },
  { value: 'Sheath Blight', label: 'Sheath Blight' },
];

export const Samples: React.FC = () => {
  const [data, setData] = useState<PaginatedResponse<UncertainSample> | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [page, setPage] = useState<number>(1);
  const [region, setRegion] = useState<string>('');
  const [disease, setDisease] = useState<string>('');
  const [viewMode, setViewMode] = useState<'grid' | 'table'>('grid');

  const fetchSamples = async () => {
    setLoading(true);
    try {
      const res = await expertApi.getPendingSamples({
        page,
        limit: 9,
        region: region || undefined,
        disease: disease || undefined,
      });
      setData(res);
    } catch {
      // Error handling handled gracefully
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSamples();
  }, [page, region, disease]);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.75rem' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#f8fafc' }}>
            Pending Samples Queue
          </h1>
          <p style={{ fontSize: '0.875rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
            Uncertain predictions (&lt; 0.80 confidence) awaiting expert ground-truth verification
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          {/* View mode toggle */}
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
          </div>

          <button onClick={fetchSamples} className="btn-secondary" style={{ padding: '0.55rem 0.85rem' }}>
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
          <Filter size={18} color="#10b981" />
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

        <select
          value={disease}
          onChange={(e) => {
            setDisease(e.target.value);
            setPage(1);
          }}
          style={{ minWidth: '200px' }}
        >
          {DISEASES.map((d) => (
            <option key={d.value} value={d.value}>
              {d.label}
            </option>
          ))}
        </select>

        {(region || disease) && (
          <button
            onClick={() => {
              setRegion('');
              setDisease('');
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
          Showing <strong>{data?.items.length || 0}</strong> of <strong>{data?.total || 0}</strong> pending samples
        </div>
      </div>

      {/* Main Content View */}
      {loading ? (
        <Loading message="Fetching pending uncertain samples..." />
      ) : viewMode === 'grid' ? (
        data?.items && data.items.length > 0 ? (
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
            <p style={{ fontSize: '1.1rem', fontWeight: 600, color: '#f8fafc' }}>No Pending Samples Found</p>
            <span style={{ fontSize: '0.85rem' }}>No pending samples match your chosen filter options.</span>
          </div>
        )
      ) : (
        <SampleTable samples={data?.items || []} />
      )}

      {/* Pagination Footer */}
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
