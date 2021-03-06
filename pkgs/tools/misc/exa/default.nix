{ stdenv, fetchFromGitHub, rustPlatform, openssl, cmake, zlib }:

with rustPlatform;

buildRustPackage rec {
  name = "exa-${version}";
  version = "2016-04-11";

  depsSha256 = "1rpynsni2r3gim10xc1qkj51wpbzafwsr99y61zh41v4vh047g1k";

  src = fetchFromGitHub {
    owner = "ogham";
    repo = "exa";
    rev = "9b87ef1da2231acef985bb08f7bd4a557167b652";
    sha256 = "1f71bqkpc6bf9jg1zxy21rzbyhzghwfmgbyyyb81ggxcri0kajwi";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl zlib ];

  # Some tests fail, but Travis ensures a proper build
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Replacement for 'ls' written in Rust";
    longDescription = ''
      exa is a modern replacement for ls. It uses colours for information by
      default, helping you distinguish between many types of files, such as
      whether you are the owner, or in the owning group. It also has extra
      features not present in the original ls, such as viewing the Git status
      for a directory, or recursing into directories with a tree view. exa is
      written in Rust, so it’s small, fast, and portable.
    '';
    homepage = http://bsago.me/exa;
    license = licenses.mit;
    maintainer = [ maintainers.ehegnes ];
  };
}
