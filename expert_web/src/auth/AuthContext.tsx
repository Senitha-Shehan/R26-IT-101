import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { ExpertUser, authStorage } from './authStorage';
import { expertApi } from '../api/expertApi';

interface AuthContextType {
  user: ExpertUser | null;
  token: string | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<ExpertUser | null>(authStorage.getUser());
  const [token, setToken] = useState<string | null>(authStorage.getToken());
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    const initAuth = async () => {
      const storedToken = authStorage.getToken();
      if (storedToken) {
        try {
          const fetchedUser = await expertApi.getMe();
          setUser(fetchedUser);
          authStorage.setUser(fetchedUser);
        } catch {
          authStorage.clear();
          setUser(null);
          setToken(null);
        }
      }
      setIsLoading(false);
    };

    initAuth();
  }, []);

  const login = async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const result = await expertApi.login(email, password);
      setToken(result.access_token);
      setUser(result.user);
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    authStorage.clear();
    setToken(null);
    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isLoading,
        login,
        logout,
        isAuthenticated: !!token && !!user,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
