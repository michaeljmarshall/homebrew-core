class Bazelisk < Formula
  desc "User-friendly launcher for Bazel"
  homepage "https://github.com/bazelbuild/bazelisk/"
  url "https://github.com/bazelbuild/bazelisk.git",
      tag:      "v1.14.1",
      revision: "d1565d8213492a2d380c8a07a1061268f12d65bb"
  license "Apache-2.0"
  head "https://github.com/bazelbuild/bazelisk.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "49d3547592a2fc9e6242c935d58746b651bce35f3cad9fb42fcfcad7b4c4d49b"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5309d94ada31d70915b332a092501aa68f883a341ea3125372758502ec4ac4c2"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "5062b037190e7a38139df1cc5c5f61b76e307dfe0616d843e2f399790edfe825"
    sha256 cellar: :any_skip_relocation, monterey:       "506c1c7402d3516f143a789f13198c3b982386f83a2f954010a6aea8f2271a00"
    sha256 cellar: :any_skip_relocation, big_sur:        "278dea33c148642a18f42f0773653573719a014a19a5d924e60a3cd4fe2b213d"
    sha256 cellar: :any_skip_relocation, catalina:       "236e1857190b6f638ba443d25a8311adbb1151d1f48ba737e66f3975dbe9f4d4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "f20f59f6ea78eae466de57e275002b3258adc1825b3ee0268b9598fe69081715"
  end

  depends_on "go" => :build

  conflicts_with "bazel", because: "Bazelisk replaces the bazel binary"

  resource "bazel_zsh_completion" do
    url "https://raw.githubusercontent.com/bazelbuild/bazel/036e533/scripts/zsh_completion/_bazel"
    sha256 "4094dc84add2f23823bc341186adf6b8487fbd5d4164bd52d98891c41511eba4"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.BazeliskVersion=#{version}")

    bin.install_symlink "bazelisk" => "bazel"

    resource("bazel_zsh_completion").stage do
      zsh_completion.install "_bazel"
    end
  end

  test do
    ENV["USE_BAZEL_VERSION"] = Formula["bazel"].version
    assert_match "Build label: #{Formula["bazel"].version}", shell_output("#{bin}/bazelisk version")

    # This is an older than current version, so that we can test that bazelisk
    # will target an explicit version we specify. This version shouldn't need to
    # be bumped.
    bazel_version = Hardware::CPU.arm? ? "4.1.0" : "4.0.0"
    ENV["USE_BAZEL_VERSION"] = bazel_version
    assert_match "Build label: #{bazel_version}", shell_output("#{bin}/bazelisk version")
  end
end
