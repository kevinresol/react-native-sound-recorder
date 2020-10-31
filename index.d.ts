declare module 'react-native-sound-recorder' {
  export function start(path: string, options?: object): Promise<void>;
  export function stop(): Promise<{ path: string; duration: number }>;
  export function pause(): Promise<void>;
  export function resume(): Promise<void>;

  // Constants
  export const PATH_CACHE: string;
  export const PATH_DOCUMENT: string;
  export const PATH_LIBRARY: string;
}
