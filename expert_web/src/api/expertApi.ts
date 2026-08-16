import { apiClient } from './apiClient';
import { ExpertUser, authStorage } from '../auth/authStorage';

export interface DashboardStats {
  pending_review: number;
  reviewed: number;
  total: number;
}

export interface UncertainSample {
  id?: string;
  sample_id: string;
  image_path: string;
  predicted_disease: string;
  confidence: number;
  region: string;
  model_id: string;
  status: string;
  created_at: string;
  uploaded_at: string;
  expert_label?: string | null;
  expert_notes?: string | null;
  reviewed_at?: string | null;
  reviewed_by?: string | null;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  pages: number;
}

export interface ReviewSubmissionPayload {
  sample_id: string;
  expert_label: string;
  expert_notes?: string;
}

export const expertApi = {
  async login(email: string, password: string): Promise<{ access_token: string; user: ExpertUser }> {
    const data = await apiClient<{ access_token: string; user: ExpertUser }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    authStorage.setToken(data.access_token);
    authStorage.setUser(data.user);
    return data;
  },

  async getMe(): Promise<ExpertUser> {
    return apiClient<ExpertUser>('/auth/me');
  },

  async getDashboardStats(): Promise<DashboardStats> {
    return apiClient<DashboardStats>('/expert/dashboard-stats');
  },

  async getDiseaseClasses(): Promise<string[]> {
    return apiClient<string[]>('/expert/disease-classes');
  },

  async getPendingSamples(params: {
    page?: number;
    limit?: number;
    region?: string;
    disease?: string;
    min_confidence?: number;
    max_confidence?: number;
  } = {}): Promise<PaginatedResponse<UncertainSample>> {
    const query = new URLSearchParams();
    if (params.page) query.append('page', params.page.toString());
    if (params.limit) query.append('limit', params.limit.toString());
    if (params.region) query.append('region', params.region);
    if (params.disease) query.append('disease', params.disease);
    if (params.min_confidence !== undefined) query.append('min_confidence', params.min_confidence.toString());
    if (params.max_confidence !== undefined) query.append('max_confidence', params.max_confidence.toString());

    return apiClient<PaginatedResponse<UncertainSample>>(`/expert/pending-samples?${query.toString()}`);
  },

  async getReviewedSamples(params: {
    page?: number;
    limit?: number;
    region?: string;
    ai_disease?: string;
    expert_disease?: string;
    reviewer?: string;
  } = {}): Promise<PaginatedResponse<UncertainSample>> {
    const query = new URLSearchParams();
    if (params.page) query.append('page', params.page.toString());
    if (params.limit) query.append('limit', params.limit.toString());
    if (params.region) query.append('region', params.region);
    if (params.ai_disease) query.append('ai_disease', params.ai_disease);
    if (params.expert_disease) query.append('expert_disease', params.expert_disease);
    if (params.reviewer) query.append('reviewer', params.reviewer);

    return apiClient<PaginatedResponse<UncertainSample>>(`/expert/reviewed-samples?${query.toString()}`);
  },

  async getSampleDetail(sampleId: string): Promise<UncertainSample> {
    return apiClient<UncertainSample>(`/uncertain-samples/${sampleId}`);
  },

  async getSampleImageUrl(sampleId: string): Promise<string> {
    const token = authStorage.getToken();
    const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';
    const baseUrl = API_BASE_URL.startsWith('http') ? API_BASE_URL : `${window.location.origin}${API_BASE_URL}`;
    
    // Fetch image blob with Bearer token for protected image endpoint
    const response = await fetch(`${baseUrl}/uncertain-samples/${sampleId}/image`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    if (!response.ok) {
      throw new Error('Failed to load sample image');
    }
    const blob = await response.blob();
    return URL.createObjectURL(blob);
  },

  async submitReview(payload: ReviewSubmissionPayload): Promise<{ message: string; sample: UncertainSample }> {
    return apiClient<{ message: string; sample: UncertainSample }>('/expert/reviews', {
      method: 'POST',
      body: JSON.stringify(payload),
    });
  },
};
