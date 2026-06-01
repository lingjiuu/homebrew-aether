class Aether < Formula
  desc "Minimal but powerful agent in your terminal"
  homepage "https://github.com/lingjiuu/aether"
  url "https://github.com/lingjiuu/aether/releases/download/v0.2.0/lingjiuu-aether-0.2.0.tgz"
  sha256 "8bcaa3924fa50ad3f37fa9d63302f937007596c511d74f4fa98a778aefba29e6"

  depends_on "node"

  if OS.mac? && Hardware::CPU.arm?
    resource "aether-backend" do
      url "https://github.com/lingjiuu/aether/releases/download/v0.2.0/lingjiuu-aether-darwin-arm64-0.2.0.tgz"
      sha256 "dd591dc1891266c4ef2be4b1cb87ab6449378c243484fc606be58647eeed5eca"
    end
  elsif OS.mac? && Hardware::CPU.intel?
    resource "aether-backend" do
      url "https://github.com/lingjiuu/aether/releases/download/v0.2.0/lingjiuu-aether-darwin-x64-0.2.0.tgz"
      sha256 "917a142cfa7c7d826252048834ee1af54a602e396923c8d48f9afc332971f730"
    end
  end

  def install
    odie "Aether's Homebrew formula currently supports macOS only." unless OS.mac?

    ENV.prepend_path "PATH", Formula["node"].opt_bin

    system "npm", "install", *std_npm_args(prefix: libexec), "--omit=optional", "--ignore-scripts"

    package_root = libexec/"lib/node_modules/@lingjiuu/aether"
    resource("aether-backend").stage do
      package_root.install "backend"
      package_root.install "runtime"
    end
    chmod 0755, package_root/"runtime/bin/java"

    (bin/"aether").write <<~EOS
      #!/bin/bash
      export AETHER_BACKEND_COMMAND="#{package_root}/runtime/bin/java"
      export AETHER_BACKEND_ARGS="-jar #{package_root}/backend/aether-backend.jar --stdio"
      exec "#{Formula["node"].opt_bin}/node" "#{package_root}/dist/main.js" "$@"
    EOS
  end

  test do
    package_root = libexec/"lib/node_modules/@lingjiuu/aether"
    assert_path_exists package_root/"dist/main.js"
    assert_path_exists package_root/"backend/aether-backend.jar"
    assert_path_exists package_root/"runtime/bin/java"
    assert_path_exists bin/"aether"
  end
end
