/**
 * Cross-platform business logic shared between web (apps/web) and mobile (apps/mobile).
 *
 * What belongs here:
 * - Shared TypeScript types (User, Subscription, etc.)
 * - Pure validation functions (zod schemas, derived state)
 * - Calculations that don't depend on platform APIs
 * - Constants used in both apps
 *
 * What does NOT belong here:
 * - UI components (web and mobile render differently — keep components per-app)
 * - Convex queries/mutations (those live in @kit/backend)
 * - Platform-specific code (use of window/document, AsyncStorage, etc.)
 */
export {};
