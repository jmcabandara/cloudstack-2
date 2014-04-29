LANG=C

if $(rpm -qi --quiet cloudstack-common); then
  _CCP_VER=$(rpm -qa | grep cloudstack-common | sed -e 's/.*-\(.*\)-.*/\1/')
  _INSTALL=/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt
elif $(rpm -qi --quiet cloud-setup); then
  _CCP_VER=$(rpm -qa | grep cloud-setup | sed -e 's/.*-\(.*\)-.*/\1/')
  _INSTALL=/usr/lib64/cloud/agent/scripts/storage/secondary/cloud-install-sys-tmplt
else
  echo CloudPlatform is not installed yet.
  exit 1
fi

_SSDIR=/export/secondary
_DLURL=http://download.cloud.com/templates
_ACTON=acton/acton-systemvm-02062012
_BURBANK=burbank/burbank-systemvm-08012012
_CAMPO=4.2/systemvmtemplate
_FELTON=4.3/systemvm64template

for _hv in kvm kvm64 xenserver xenserver64 vmware vmware64 hyperv; do
  case $_hv in
    kvm64)
        _hv=${_hv%64}
	case $_CCP_VER in
	  4\.3*)	_rel=${_FELTON}-2014-04-10-master-$_hv ;;
	  *)		continue ;;
	esac
	_ext='qcow2.bz2' ;;
    kvm)
	case $_CCP_VER in
	  4\.2*)	_rel=${_CAMPO}-2014-04-15-master-$_hv ;;
	  3\.*)		_rel=${_ACTON} ;;
	  *)		continue ;;
	esac
	_ext='qcow2.bz2' ;;
    xenserver64)
        _hv=${_hv%64}
	case $_CCP_VER in
	  4\.3*)	_rel=${_FELTON}-2014-04-10-master-xen ;;
	  *)		continue ;;
	esac
	_ext='vhd.bz2' ;;
    xenserver)
	case $_CCP_VER in
	  4\.2*)	_rel=${_CAMPO}-2014-04-15-master-xen ;;
	  3\.*)		_rel=${_ACTON} ;;
	  *)		continue ;;
	esac
	_ext='vhd.bz2' ;;
    vmware)
	case $_CCP_VER in
	  4\.2*)	_rel=${_CAMPO}-2014-04-16-master-vmware ;;
	  3\.0\.[5-7])	_rel=${_BURBANK} ;;
	  3\.*)		_rel=${_ACTON} ;;
	  *)		continue ;;
	esac
	_ext='ova' ;;
    vmware64)
        _hv=${_hv%64}
	case $_CCP_VER in
	  4\.3*)	_rel=${_FELTON}-2014-04-13-master-$_hv ;;
	  *)		continue ;;
	esac
	_ext='ova' ;;
    hyperv)
	case $_CCP_VER in
	  4\.3*)	_rel=${_FELTON}-2014-04-10-master-$_hv ;;
	  *)		continue ;;
	esac
	_ext='vhd.bz2' ;;
  esac
  $_INSTALL -m $_SSDIR -u ${_DLURL}/${_rel}.${_ext} -h $_hv -F
done
