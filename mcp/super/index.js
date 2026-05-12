import { Server } from "@modelcontextprotocol/sdk/server";
import codeIntel from "./engines/code_intel.js";
import autoFix from "./engines/auto_fix.js";
import generator from "./engines/generator.js";
import dbAnalyzer from "./engines/db_analyzer.js";
import security from "./engines/security.js";
import architecture from "./engines/architecture.js";

const server = new Server({
  name: "super-mcp",
  version: "1.0.0"
});

// Code Intelligence
server.tool("analyze_codebase", codeIntel);

// Auto Fix
server.tool("auto_fix", autoFix);

// Generator
server.tool("generate", generator);

// DB Analyzer
server.tool("analyze_db", dbAnalyzer);

// Security Scanner
server.tool("security_scan", security);

// Architecture Advisor
server.tool("architecture_review", architecture);

server.start();
