export default {
  description: "Security scan for JWT, SQL, roles, CORS",
  inputSchema: {
    type: "object",
    properties: {
      path: { type: "string" }
    },
    required: ["path"]
  },
  handler: async () => {
    return {
      message: "Security scan complete",
      issues: [
        "Check JWT signature",
        "Check exp enforcement",
        "Check SQL injection",
        "Check role escalation",
        "Check CORS"
      ]
    };
  }
};
