{ lib
, stdenv
, python
, buildPythonPackage
, fetchFromGitHub
, abseil-cpp
, eigen
, flatbuffers
, cmake
, pybind11
, numpy
}:
let
  farmhash = stdenv.mkDerivation {
    pname = "farmhash";
    version = "";

    src = fetchFromGitHub {
      owner = "google";
      repo = "farmhash";
      rev = "0d859a811870d10f53a594927d0d0b97573ad06d";
      sha256 = "sha256-J0AhHVOvPFT2SqvQ+evFiBoVfdHthZSBXzAhUepARfA=";
    };

    dontDisableStatic = true;

    postInstall = ''
      mkdir -p $out/lib/cmake/farmhash/
      cp ${./farmhash.cmake} $out/lib/cmake/farmhash/farmhash-config.cmake
    '';
  };

  gemmlowp = stdenv.mkDerivation {
    name = "gemmlowp";

    src = fetchFromGitHub {
      owner = "google";
      repo = "gemmlowp";
      rev = "fda83bdc38b118cc6b56753bd540caa49e570745";
      sha256 = "sha256-tE+w72sfudZXWyMxG6CGMqXYswve57/cpvwrketEd+k=";
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/include/
      cp -r public/ internal/ fixedpoint/ profiling/ meta/ $out/include/
      mkdir -p $out/lib/cmake/gemmlowp
      cp ${./gemmlowp.cmake} $out/lib/cmake/gemmlowp/gemmlowp-config.cmake
    '';
  };

  cpuinfo = stdenv.mkDerivation {
    name = "cpuinfo";

    src = fetchFromGitHub {
      owner = "pytorch";
      repo = "cpuinfo";
      rev = "5e63739504f0f8e18e941bd63b2d6d42536c7d90";
      sha256 = "sha256-5no9LkQIIOIidvhera5lIbnOUkcZQtW4nIUqXSLnWHA=";
    };

    nativeBuildInputs = [ cmake ];

    postPatch = ''
      sed -i 's#JOIN_PATHS(libdir_for_pc_file "\$${exec_prefix}" "$${CMAKE_INSTALL_LIBDIR}")#set(libdir_for_pc_file "$${CMAKE_INSTALL_FULL_LIBDIR}")#g' CMakeLists.txt
    '';

    cmakeFlags = [
      "-DCPUINFO_BUILD_UNIT_TESTS=OFF"
      "-DCPUINFO_BUILD_MOCK_TESTS=OFF"
      "-DCPUINFO_BUILD_BENCHMARKS=OFF"
    ];
  };

  ruy = stdenv.mkDerivation {
    name = "ruy";

    src = fetchFromGitHub {
      owner = "google";
      repo = "ruy";
      rev = "841ea4172ba904fe3536789497f9565f2ef64129";
      sha256 = "sha256-Hl0kC+qkTPZrN020maMmyhIf/74FTcq5t6VAajDQ+e8=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ cmake ];

    cmakeBuildDir = "builddir";
  };

  neon-2-sse = stdenv.mkDerivation {
    name = "NEON_2_SSE";

    src = fetchFromGitHub {
        owner = "intel";
        repo = "ARM_NEON_2_x86_SSE";
        rev = "a15b489e1222b2087007546b4912e21293ea86ff";
        sha256 = "sha256-299ZptvdTmCnIuVVBkrpf5ZTxKPwgcGUob81tEI91F0=";
    };

    nativeBuildInputs = [ cmake ];
  };

  psimd = fetchFromGitHub {
    owner = "Maratyszcza";
    repo = "psimd";
    rev = "072586a71b55b7f8c584153d223e95687148a900";
    sha256 = "sha256-lV+VZi2b4SQlRYrhKx9Dxc6HlDEFz3newvcBjTekupo=";
  };

  fp16 = stdenv.mkDerivation {
    name = "FP16";

    src = fetchFromGitHub {
      owner = "Maratyszcza";
      repo = "FP16";
      rev = "0a92994d729ff76a58f692d3028ca1b64b145d91";
      sha256 = "sha256-m2d9bqZoGWzuUPGkd29MsrdscnJRtuIkLIMp3fMmtRY=";
    };

    nativeBuildInputs = [ cmake ];

    cmakeFlags = [
      "-DPSIMD_SOURCE_DIR=${psimd}"
      # Tests won't build with gcc.
      "-DFP16_BUILD_BENCHMARKS=OFF"
    ];
  };

  xnnpack = stdenv.mkDerivation {
    name = "XNNPACK";

    src = fetchFromGitHub {
      owner = "google";
      repo = "XNNPACK";
      rev = "c0217274082a2a42c64d17a18c3f4a2a3e067157";
      sha256 = "sha256-ymS2dAbVvnYxifcm58nINWXJMuLomnE0SalkdoabBLM=";
    };

    nativeBuildInputs = [ cmake ];

    cmakeFlags = [
      "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON"
      # Unnecessary and slows down build
      "-DXNNPACK_BUILD_BENCHMARKS=OFF"
      "-DXNNPACK_BUILD_TESTS=OFF"
      "-DPSIMD_SOURCE_DIR=${psimd}"
      "-Dfp16_DIR=${fp16}/lib/cmake/FP16"
    ];

    postInstall = ''
      mkdir -p $out/lib/cmake/XNNPACK/
      cp ${./xnnpack.cmake} $out/lib/cmake/XNNPACK/XNNPACK-config.cmake
    '';
  };
  src = fetchFromGitHub {
    owner = "tensorflow";
    repo = "tensorflow";
    #rev = "v${version}";
    #sha256 = "sha256-Y6cujiMoQXKQlsLBr7d0T278ltdd00IfsTRycJbRVN4";
    rev = "69716bf9cc0448bc42980039c97e6960b2211ac3";
    sha256 = "sha256-D+O+S+S6qTQEW2Nl0Z1X7DLdUZm4htMarHP8shvgMP4=";
  };
  tensorflow-wrapper = stdenv.mkDerivation {
    name = "tensorflow-interpreter-wrapper";
    inherit src;

    nativeBuildInputs = [ cmake ];
    buildInputs = [ ];

    cmakeDir = "../tensorflow/lite";
    cmakeBuildDir = "builddir";
    cmakeFlags = [
      "-DTFLITE_ENABLE_INSTALL=ON"
      "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON"
      "-Dabsl_DIR=${abseil-cpp}/lib/cmake/absl"
      "-DEigen3_DIR=${eigen}/share/eigen3/cmake"
      "-Dfarmhash_DIR=${farmhash}/lib/cmake/farmhash"
      "-DFlatbuffers_DIR=${flatbuffers}/lib/cmake/flatbuffers"
      "-Dgemmlowp_DIR=${gemmlowp}/lib/cmake/gemmlowp"
      "-DNEON_2_SSE_DIR=${neon-2-sse}/lib/cmake/NEON_2_SSE"
      "-Dcpuinfo_DIR=${cpuinfo}/share/cpuinfo"
      "-Druy_DIR=${ruy}/lib/cmake/ruy"
      "-DXNNPACK_DIR=${xnnpack}/lib/cmake/XNNPACK"
      "-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
    ];

    # For whatever reason, cmakeFlags doesn't like values with spaces. So
    # instead of going through CMAKE_C_FLAGS and CMAKE_CXX_FLAGS, we'll just
    # abuse CFLAGS/CXXFLAGS.
    preConfigure = ''
      export CFLAGS="-I${lib.getDev python}/include/${python.libPrefix} -I${pybind11}/include -I${numpy}/${python.sitePackages}/numpy/core/include"
      export CXXFLAGS="-I${lib.getDev python}/include/${python.libPrefix} -I${pybind11}/include -I${numpy}/${python.sitePackages}/numpy/core/include"
      export LDFLAGS="-L${python}/lib -lpython3.10"
    '';

    buildFlags = ["_pywrap_tensorflow_interpreter_wrapper"];

    installPhase = ''
      mkdir -p $out/lib
      ls -laR
      cp _pywrap_tensorflow_interpreter_wrapper.* $out/lib/_pywrap_tensorflow_interpreter_wrapper.so
    '';
  };
in
buildPythonPackage rec {
  pname = "tflite-runtime";
  version = "2.10.0";

  inherit src;

  propagatedBuildInputs = [ numpy ];

  configurePhase = ''
    TENSORFLOW_LITE_DIR=$(pwd)/tensorflow/lite
    BUILD_DIR=$(pwd)/builddir

    mkdir -p $BUILD_DIR/tflite_runtime

    cp -r "$TENSORFLOW_LITE_DIR/tools/pip_package/debian" \
      "$TENSORFLOW_LITE_DIR/tools/pip_package/MANIFEST.in" \
      "$TENSORFLOW_LITE_DIR/python/interpreter_wrapper" \
      "$BUILD_DIR"
    cp "$TENSORFLOW_LITE_DIR/tools/pip_package/setup_with_binary.py" "$BUILD_DIR/setup.py"
    cp "$TENSORFLOW_LITE_DIR/python/interpreter.py" \
       "$TENSORFLOW_LITE_DIR/python/metrics/metrics_interface.py" \
       "$TENSORFLOW_LITE_DIR/python/metrics/metrics_portable.py" \
       "$BUILD_DIR/tflite_runtime"

    echo "__version__ = '${version}'" >> "$BUILD_DIR/tflite_runtime/__init__.py"

    cp ${tensorflow-wrapper}/lib/_pywrap_tensorflow_interpreter_wrapper.so "$BUILD_DIR/tflite_runtime"
  '';

  preBuild = ''
    cd "$BUILD_DIR"
    export PROJECT_NAME=tflite_runtime
    export PACKAGE_VERSION=${version}
  '';
}
