class Aether < Formula
  desc "Minimal but powerful agent in your terminal"
  homepage "https://github.com/lingjiuu/aether"
  url "https://github.com/lingjiuu/aether/releases/download/v0.1.0/lingjiuu-aether-0.1.0.tgz"
  sha256 "ee54403ffa064aa0fe91fb6ba84616eb33fc9ed2ce8c6aa89736b5d61b4fc926"
  version "0.1.0"

  depends_on "node"

  if OS.mac? && Hardware::CPU.arm?
    resource "aether-backend" do
      url "https://github.com/lingjiuu/aether/releases/download/v0.1.0/lingjiuu-aether-darwin-arm64-0.1.0.tgz"
      sha256 "378dae18cefce3096bf9a3ae1f3bf83d8d25a0eadc85528ca8432c0a1463bbe3"
    end
  elsif OS.mac? && Hardware::CPU.intel?
    resource "aether-backend" do
      url "https://github.com/lingjiuu/aether/releases/download/v0.1.0/lingjiuu-aether-darwin-x64-0.1.0.tgz"
      sha256 "c100f9f99a109983ea14c4c4445de94dbf5ec973d0ee4f93b1a5c23dd11aa776"
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
