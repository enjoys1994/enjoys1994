#!/usr/bin


cp tcl8.4.19-src.tar.gz  /usr/local/src/
cp expect5.45.tar.gz /usr/local/src/

cd /usr/local/src/

tar -zxvf tcl8.4.19-src.tar.gz
tar -zxvf expect5.45.tar.gz

cd tcl8.4.19/unix/

sudo ./configure && sudo  make && sudo make install

cd /usr/local/src/expect5.45/
sudo ./configure --with-tclinclude=/usr/local/src/tcl8.4.19/generic/ --with-tclconfig=/usr/local/lib/ && sudo make && sudo make install


