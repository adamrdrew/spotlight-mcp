# Project Documentation

## Spotlight MCP — macOS Spotlight MCP Server

An MCP server in Swift that exposes macOS Spotlight search to LLMs via stdio JSON-RPC. Four tools: `search`, `get_metadata`, `search_by_kind`, `recent_files`.

## Table of Contents

- [Search Module](search-module.md) — Spotlight query engine: SpotlightQuery, QueryBuilder, MetadataItem, KindMapping, types
- [Tool Layer](tool-layer.md) — MCP tool handlers, routing, argument validation, path sanitization, pagination, logging, and error handling
