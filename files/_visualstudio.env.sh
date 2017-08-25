
# NB. "progra~2" is short for "Program Files (x86)", but sh barfs upon parentheses

# visual studio vars
vsversion="14.11.25503"
vsrootdir="C:/visualstudio"
vsplatform="x64"
#################################
## ideally, no need to edit below
#################################

winkitsrootdir="C:/Progra~2/Windows Kits"
winsdkrootdir="C:/Progra~2/Microsoft SDKs"
winsdkexedir="C:/Progra~2/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.6.1 Tools/$vsplatform/"
msbuildrootdir="C:/PROGRA~2/MSBuild"

# vs paths
vsbatfile="$vsrootdir/VC/Auxiliary/Build/vcvarsall.bat"
vsbinpath="$vsrootdir/VC/Tools/MSVC/$vsversion/bin/Host$vsplatform/$vsplatform/"
clexe="$vsbinpath/cl.exe"

if [[ ! -f "$vsbatfile" ]]; then
  echo "file '$vsbatfile' does not exist! your VS installation might be broken." >&2
fi
includepaths=(
  "$vsrootdir/VC/Tools/MSVC/$vsversion/include/"
  "$vsrootdir/VC/Tools/MSVC/$vsversion/atlmfc/include"
  "$winkitsrootdir/10/Include/10.0.15063.0/ucrt/"
  "$winkitsrootdir/8.1/Include/winrt/"
  "$winkitsrootdir/8.1/Include/um/"
  "$winkitsrootdir/8.1/Include/shared/"
  "c:/Progra~2/Windows Kits/NETFXSDK/4.6.1/Lib/um/x64"
)
libdirs=(
  "$vsrootdir/VC/Tools/MSVC/$vsversion/lib/$vsplatform"
  "$winkitsrootdir/8.1/Lib/winv6.3/um/$vsplatform"
  "$winkitsrootdir/10/Lib/10.0.15063.0/ucrt/$vsplatform"
  "c:/Progra~2/Windows Kits/NETFXSDK/4.6.1/Lib/um/x64"
)
libpaths=(
  "References/CommonConfiguration/Neutral"
  "/Microsoft.VCLibs/$vsversion/References/CommonConfiguration/neutral"
  "c:/Progra~2/Windows Kits/NETFXSDK/4.6.1/Lib/um"
  "c:/Progra~2/Windows Kits/NETFXSDK/4.6.1/Lib/um/x64"
)


#######################################################
#######################################################
## environment variables needed by cl.exe start here ##
#######################################################
#######################################################

vcdelim=";"

# add $vsbinpath to PATH
export PATH="$PATH:$(cygpath -a "$vsbinpath")"

# now export the rest
#export FrameworkDir="C:/Windows/Microsoft.NET/Framework"
#export FrameworkDIR32="C:/Windows/Microsoft.NET/Framework/"
#export FrameworkVersion="v4.0.30319"
#export FrameworkVersion32="v4.0.30319"
export INCLUDE="$(__strjoin "$vcdelim" "${includepaths[@]}")"
export LIB="$(__strjoin "$vcdelim" "${libdirs[@]}")"
export LIBPATH="$(__strjoin "$vcdelim" "${libpaths[@]}")"
export NETFXSDKDir="$winkitsrootdir/NETFXSDK/4.6.1"
#export UCRTContentRoot="$winkitsrootdir/10/"
#export UCRTVersion="10.0.10240.0"
#export UniversalCRTSdkDir="$winkitsrootdir/10/"
#export VCINSTALLDIR="$vsrootdir/VC/"
#export VCTargetsPath="$msbuildrootdir/Microsoft.Cpp/v4.0/v140/"
#export VS140COMNTOOLS="$vsrootdir/Common7/Tools/"
export WindowsLibPath="References/CommonConfiguration/Neutral"
#export WindowsSDK_ExecutablePath_x64="$winsdkexedir"
export WindowsSdkDir="$winsdkrootdir"
export WindowsSDKLibVersion="winv6.3/"

####################################################
### unset variables ################################
####################################################
unset vsversion vsrootdir vsplatform winkitsrootdir
unset winsdkrootdir winsdkexedir msbuildrootdir vsbatfile
unset vsbinpath clexe includepaths libdirs
unset libpaths vcdelim

#set +x
