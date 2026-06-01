class Aether < Formula
  desc "Minimal but powerful agent in your terminal"
  homepage "https://github.com/lingjiuu/aether"
  url "https://github.com/lingjiuu/aether/releases/download/v0.1.1/lingjiuu-aether-0.1.1.tgz"
  sha256 "815358dd4c911a6ec54a1b0ba4a09ccd5de815738826da1eb3689324c5952973"
  version "0.1.1"
  revision 1

  depends_on "node"

  if OS.mac? && Hardware::CPU.arm?
    resource "aether-backend" do
      url "https://github.com/lingjiuu/aether/releases/download/v0.1.1/lingjiuu-aether-darwin-arm64-0.1.1.tgz"
      sha256 "e9e0d9bef7cf4332cd609ea6e7710149e1baa8b404c3b7e5eae0efd1edb5a458"
    end
  elsif OS.mac? && Hardware::CPU.intel?
    resource "aether-backend" do
      url "https://github.com/lingjiuu/aether/releases/download/v0.1.1/lingjiuu-aether-darwin-x64-0.1.1.tgz"
      sha256 "ffe62809f2bc284a2c0d716ce2ff52316f1d759672a8e1e23097887301803bdc"
    end
  end

  def install
    odie "Aether's Homebrew formula currently supports macOS only." unless OS.mac?

    ENV.prepend_path "PATH", Formula["node"].opt_bin

    system "npm", "install", *std_npm_args(prefix: libexec), "--omit=optional"

    package_root = libexec/"lib/node_modules/@lingjiuu/aether"
    resource("aether-backend").stage do
      package_root.install "bin/aether-backend"
    end
    chmod 0755, package_root/"aether-backend"

    (bin/"aether").write <<~EOS
      #!/bin/bash
      export AETHER_BACKEND_COMMAND="#{package_root}/aether-backend"
      exec "#{Formula["node"].opt_bin}/node" "#{package_root}/dist/main.js" "$@"
    EOS
  end

  test do
    package_root = libexec/"lib/node_modules/@lingjiuu/aether"
    assert_path_exists package_root/"dist/main.js"
    assert_path_exists package_root/"aether-backend"
    assert_path_exists bin/"aether"
  end
end
