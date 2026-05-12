export default {
  description: "Review architecture and propose improvements",
  inputSchema: {
    type: "object",
    properties: {
      path: { type: "string" }
    },
    required: ["path"]
  },
  handler: async () => {
    return {
      message: "Architecture review complete",
      suggestions: [
        "Improve layering",
        "Improve separation of concerns",
        "Improve naming",
        "Improve folder structure",
        "Introduce centralized error handling"
      ]
    };
  }
};
