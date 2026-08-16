import React, { useState, useEffect } from 'react';
import { ZoomIn, ZoomOut, RotateCcw, Maximize2, Image as ImageIcon } from 'lucide-react';
import { Loading } from './Loading';

interface ImageViewerProps {
  imageUrlFetcher: () => Promise<string>;
  altText: string;
}

export const ImageViewer: React.FC<ImageViewerProps> = ({ imageUrlFetcher, altText }) => {
  const [imageUrl, setImageUrl] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [zoom, setZoom] = useState<number>(1);
  const [isFullscreen, setIsFullscreen] = useState<boolean>(false);

  useEffect(() => {
    let active = true;
    setLoading(true);
    setError(null);

    imageUrlFetcher()
      .then((url) => {
        if (active) {
          setImageUrl(url);
          setLoading(false);
        }
      })
      .catch((err) => {
        if (active) {
          setError(err.message || 'Failed to load image');
          setLoading(false);
        }
      });

    return () => {
      active = false;
      if (imageUrl && imageUrl.startsWith('blob:')) {
        URL.revokeObjectURL(imageUrl);
      }
    };
  }, []);

  const handleZoomIn = () => setZoom((prev) => Math.min(prev + 0.25, 3));
  const handleZoomOut = () => setZoom((prev) => Math.max(prev - 0.25, 0.75));
  const handleResetZoom = () => setZoom(1);

  if (loading) {
    return (
      <div className="glass-card" style={{ height: '420px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Loading message="Loading protected leaf image..." />
      </div>
    );
  }

  if (error || !imageUrl) {
    return (
      <div className="glass-card" style={{ height: '420px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: '0.75rem', padding: '2rem' }}>
        <ImageIcon size={48} color="var(--accent-rose)" />
        <p style={{ color: 'var(--accent-rose)', fontWeight: 600 }}>{error || 'Unable to display image'}</p>
        <span style={{ fontSize: '0.8rem', color: 'var(--text-subtle)' }}>Check backend connection or access permissions.</span>
      </div>
    );
  }

  return (
    <div
      className="glass-card"
      style={{
        position: 'relative',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '1.25rem',
        overflow: 'hidden',
        minHeight: '450px',
        backgroundColor: 'rgba(9, 13, 22, 0.85)',
      }}
    >
      {/* Zoom Control Bar */}
      <div
        style={{
          position: 'absolute',
          top: '1rem',
          right: '1rem',
          display: 'flex',
          gap: '0.4rem',
          backgroundColor: 'rgba(15, 23, 42, 0.85)',
          padding: '0.35rem 0.65rem',
          borderRadius: '20px',
          border: '1px solid var(--border-color)',
          zIndex: 10,
          backdropFilter: 'blur(10px)',
        }}
      >
        <button
          onClick={handleZoomIn}
          title="Zoom In"
          style={{ background: 'none', color: '#f8fafc', padding: '0.2rem', borderRadius: '4px' }}
        >
          <ZoomIn size={18} />
        </button>
        <button
          onClick={handleZoomOut}
          title="Zoom Out"
          style={{ background: 'none', color: '#f8fafc', padding: '0.2rem', borderRadius: '4px' }}
        >
          <ZoomOut size={18} />
        </button>
        <button
          onClick={handleResetZoom}
          title="Reset Zoom"
          style={{ background: 'none', color: '#f8fafc', padding: '0.2rem', borderRadius: '4px' }}
        >
          <RotateCcw size={16} />
        </button>
      </div>

      {/* Image Display */}
      <div
        style={{
          width: '100%',
          height: '420px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          overflow: 'auto',
          cursor: zoom > 1 ? 'grab' : 'default',
        }}
      >
        <img
          src={imageUrl}
          alt={altText}
          style={{
            maxWidth: zoom === 1 ? '100%' : 'none',
            maxHeight: zoom === 1 ? '100%' : 'none',
            transform: `scale(${zoom})`,
            transition: 'transform 0.2s ease-out',
            borderRadius: 'var(--radius-sm)',
            objectFit: 'contain',
            boxShadow: '0 8px 24px rgba(0,0,0,0.6)',
          }}
        />
      </div>

      <div style={{ marginTop: '0.75rem', fontSize: '0.8rem', color: 'var(--text-subtle)' }}>
        Zoom: {Math.round(zoom * 100)}% &bull; High Resolution Rice Leaf Sample Inspection
      </div>
    </div>
  );
};
