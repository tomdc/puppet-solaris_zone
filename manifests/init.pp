# Class: solaris_zone
#
# This module manages solaris zones
# Requires:
#   
#
class solaris_zone {

  # use a define for multiple instances
  define zone($zip, $interface = "igb0", $zpool = "zones" ) {
    $realhostname="$name"
    $path = "/${zpool}"

    # create the zpool
    zfs {
      "$zpool/$name":
        ensure => present,
        mountpoint => "$path/$name",
        sharenfs => "off",
    }
 
    # correct perms are needed
    file { "$path/$name/":
      require => Zfs["$zpool/$name"],
      mode   => 700
    }

    # create the zone
    zone{
      "$name":
        require => [ Zfs["$zpool/$name"], File["$path/$name"] ],
        autoboot => true,
        ip => "$interface:$zip",
        path => "$path/%s",
        realhostname => $realhostname,
        sysidcfg => template("solaris_zone/sysidcfg.erb")
    }

  }
}
