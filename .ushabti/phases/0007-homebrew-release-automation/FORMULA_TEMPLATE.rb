class SpotlightMcp < Formula
  desc "MCP server exposing macOS Spotlight search to LLMs"
  homepage "https://github.com/adamrdrew/spotlight-mcp"
  url "https://github.com/adamrdrew/spotlight-mcp/releases/download/v0.1.0/spotlight-mcp-v0.1.0-universal.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  version "0.1.0"

  depends_on :macos

  def install
    bin.install "spotlight-mcp"
  end

  test do
    assert_predicate bin/"spotlight-mcp", :executable?
  end
end
