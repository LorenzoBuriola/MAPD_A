## MAPD_A

Per entrare nel computer del lab:

*  Aprire un teminale e inserire: _ssh -XL 3000:lxilinx1.fisica.unipd.it:22 username@spiro.fisica.unipd.it_

* Aprire un altro terminale e inserire: _ssh -Xp 3000 username@localhost_


Per passare i file da computer locale e computer del lab usare _scp_

Es: __scp -P 3012 .\uart_complete.zip username@localhost:~__ , 
__scp -P 3310 file.txt .__
