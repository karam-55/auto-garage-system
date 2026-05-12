export default {
  description: "Generate code (CRUD, API, Models, Screens)",
  inputSchema: {
    type: "object",
    properties: {
      type: { type: "string" },
      name: { type: "string" }
    },
    required: ["type", "name"]
  },
  handler: async ({ type, name }) => {
    return {
      message: `Generated ${type} for ${name}`
    };
  }
};
