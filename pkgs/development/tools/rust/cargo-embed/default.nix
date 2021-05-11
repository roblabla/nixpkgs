{ lib
, rustPlatform, fetchCrate
, libusb1, libftdi1, pkg-config, rustfmt }:

rustPlatform.buildRustPackage rec {
  pname = "cargo-embed";
  version = "0.10.1";

  src = fetchCrate {
    inherit pname version;
    sha256 = "1s6qwsqrr9y7hdpn23k2vcic19j4zbwisbxyp8bi7qc68329hf44";
  };

  cargoSha256 = "02bq3p8jml0wvfk5n4zks94fbz8ql0qqmc0qxf97kzj3gj6bdb7l";

  nativeBuildInputs = [ pkg-config rustfmt ];
  buildInputs = [ libusb1 libftdi1 ];

  cargoBuildFlags = [ "--features=ftdi" ];

  meta = with lib; {
    description = "A cargo extension for working with microcontrollers";
    homepage = "https://probe.rs/";
    license = with licenses; [ asl20 /* or */ mit ];
    maintainers = with maintainers; [ fooker ];
  };
}
