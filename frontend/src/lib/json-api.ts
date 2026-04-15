/**
 * JSON:API Adapter Functions
 * Pure functions for converting between JSON:API format and flat objects
 */

export interface JsonApiData {
  id: string;
  type: string;
  attributes?: Record<string, unknown>;
  relationships?: Record<string, unknown>;
}

export interface JsonApiResponse {
  data: JsonApiData | JsonApiData[];
  meta?: {
    page?: number;
    perPage?: number;
    per_page?: number;
    total?: number;
    totalPages?: number;
    total_pages?: number;
  };
}

export interface JsonApiRequest {
  data: {
    type: string;
    attributes?: Record<string, unknown>;
    relationships?: Record<string, unknown>;
  };
}

/**
 * Deserialize a JSON:API response to a flat object
 * @param response - The JSON:API response
 * @returns A flat object with id merged with attributes
 */
export function deserialize<T>(response: JsonApiResponse): T | T[] {
  const data = response.data;

  if (Array.isArray(data)) {
    return data.map((item) => deserializeItem(item)) as T[];
  }

  return deserializeItem(data) as T;
}

/**
 * Deserialize a single JSON:API data item
 * @param item - A single JSON:API data item
 * @returns A flat object
 */
function deserializeItem<T>(item: JsonApiData): T {
  const { id, attributes } = item;
  return {
    id,
    ...(attributes || {}),
  } as T;
}

/**
 * Serialize a flat object to JSON:API request format
 * @param data - The flat object to serialize
 * @param type - The JSON:API resource type
 * @returns A JSON:API request object
 */
export function serialize<T>(data: T, type: string): JsonApiRequest {
  const { id, ...attributes } = data as { id?: string; [key: string]: unknown };

  return {
    data: {
      type,
      ...(id && { id }),
      ...(Object.keys(attributes).length > 0 && { attributes }),
    },
  };
}

/**
 * Extract pagination metadata from JSON:API response
 * @param response - The JSON:API response
 * @returns Pagination metadata or undefined
 */
export function extractPaginationMeta(response: JsonApiResponse): {
  page: number;
  perPage: number;
  total: number;
  totalPages: number;
} | undefined {
  const meta = response.meta;
  if (!meta || typeof meta.page !== 'number') {
    return undefined;
  }

  return {
    page: meta.page,
    perPage: meta.perPage || meta.per_page || 20,
    total: meta.total || 0,
    totalPages: meta.totalPages || meta.total_pages || 0,
  };
}

export interface JsonApiError {
  title?: string;
  detail: string;
  status?: number;
  source?: {
    pointer?: string;
    parameter?: string;
  };
}

export interface ParsedErrors {
  baseErrors: string[];
  fieldErrors: Record<string, string>;
}

/**
 * Parse JSON:API errors into base errors and field-level errors
 * @param error - The error object from API response
 * @returns Parsed errors with base errors and field errors
 */
export function parseApiErrors(error: unknown): ParsedErrors {
  const baseErrors: string[] = [];
  const fieldErrors: Record<string, string> = {};

  if (error && typeof error === 'object') {
    const err = error as any;
    
    // Handle JSON:API error format
    if (err.errors && Array.isArray(err.errors)) {
      err.errors.forEach((apiError: JsonApiError) => {
        if (apiError.source?.pointer) {
          // Extract field name from JSON:API pointer (e.g., "/data/attributes/name" -> "name")
          const pointer = apiError.source.pointer;
          const parts = pointer.split('/');
          const fieldName = parts[parts.length - 1];
          if (fieldName) {
            fieldErrors[fieldName] = apiError.detail;
          }
        } else if (apiError.source?.parameter) {
          // Handle parameter-based errors
          fieldErrors[apiError.source.parameter] = apiError.detail;
        } else {
          // Base error (no specific field)
          baseErrors.push(apiError.detail);
        }
      });
    } else if (err.message) {
      // Handle simple error messages
      baseErrors.push(err.message);
    }
  } else if (typeof error === 'string') {
    baseErrors.push(error);
  }

  return { baseErrors, fieldErrors };
}
