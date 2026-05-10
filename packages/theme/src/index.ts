/**
 * Shared design tokens for both web (Tailwind / shadcn) and mobile (NativeWind).
 *
 * This file is a placeholder. Real tokens are populated at Stage 3 (Brand Lock)
 * by extracting variables from the Figma file via the Figma MCP server.
 *
 * Conventions:
 * - Hex strings only here (no platform-specific units)
 * - Spacing as numbers in px (web converts via Tailwind config; mobile uses raw)
 * - Add semantic role tokens (bg/primary, text/muted, etc) as the design system grows
 */
export const theme = {
  colors: {
    bg: '#000000',
    fg: '#ffffff',
    accent: '#ff2d55',
    muted: '#666666',
    border: '#222222',
  },
  space: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
  },
  radii: {
    sm: 6,
    md: 12,
    lg: 24,
    full: 9999,
  },
  fontSizes: {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 20,
    xl: 24,
    xxl: 32,
  },
} as const;

export type Theme = typeof theme;
