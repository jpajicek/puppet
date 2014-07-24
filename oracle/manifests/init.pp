
class oracle {

 case $::operatingsystem {
    debian, ubuntu: {
                include oracle::debian::server
                include oracle::debian::swap
                include oracle::debian::xe
    }
    centos, redhat: {
		include oracle::centos::deps
		include oracle::centos::server

    }
    default: { fail("Not supported OS") }
  }

}
