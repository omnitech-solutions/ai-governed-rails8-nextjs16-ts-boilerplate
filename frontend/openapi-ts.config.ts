const config = {
  input: "./openapi.json",
  output: "./src/api/generated",
  client: "@hey-api/client-fetch",
  plugins: ["@tanstack/react-query"],
  types: {
    enums: "javascript",
  },
};

export default config;
