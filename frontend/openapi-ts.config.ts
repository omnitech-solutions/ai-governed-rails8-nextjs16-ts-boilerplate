import { defineConfig } from '@hey-api/openapi-ts';

export default defineConfig({
  input: './openapi.json',
  output: './src/api/generated',
  client: '@hey-api/client-fetch',
  plugins: ['@tanstack/react-query'],
  types: {
    enums: 'javascript',
  },
});
