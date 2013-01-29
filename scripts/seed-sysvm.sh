_INSTALL=/usr/lib64/cloud/agent/scripts/storage/secondary/cloud-install-sys-tmplt
_SSDIR=/export/secondary
_DLURL=http://download.cloud.com/templates
_ACTON=acton/acton-systemvm-02062012
_BURBANK=burbank/burbank-systemvm-08012012

LANG=C
for _hv in kvm xenserver vmware; do
  _rel=
  _ext=
  case $_hv in
    kvm)	_rel=$_ACTON; _ext='qcow2.bz2' ;;
    xenserver)	_rel=$_ACTON; _ext='vhd.bz2' ;;
    vmware)	_rel=$_BURBANK; _ext='ova' ;;
  esac
  $_INSTALL -m $_SSDIR -u ${_DLURL}/${_rel}.${_ext} -h $_hv -F
done
