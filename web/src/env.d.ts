/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_DEV: string;
  readonly VITE_USER_ROLE: 'admin' | 'mod' | 'player'
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}