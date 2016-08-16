# VagrantCI

a Poor Man's CI System using Vagrant and VirtualBox

### Overview
microG GmsCore is a free and open implementation of the Google Play Services Framework.

### Features
- a CI System (almost compatible with circle CI command syntax)
- Free and open source (Apache 2.0 licensed)
- supports only repositories hosted on github (for now)

### System Requirements
- VirtualBox    [https://www.virtualbox.org/]
- Vagrant       [https://www.vagrantup.com/]
- git           [https://en.wikipedia.org/wiki/Git_%28software%29]
- minimum 10GByte free diskspace
- minimum 8GByte RAM

### Installation (on Ubuntu)
- install requirements:
<pre>apt-get install virtualbox vagrant git</pre>
- create a dummy user that only has access to it's own homedir
- change to that dummy user
- clone repository you want to run in your CI machine:
<pre>git clone https://github.com/zoff99/Etar-Calendar.git
cd Etar-Calendar</pre>
- checkout the commit you want to run:
<pre>git checkout 32f1508713f95b1b6188f32bfcc7f0388170ace4</pre>
- now add VagrantCI to the mix:
<pre>git clone https://github.com/zoff99/_vagrantci_.git</pre>
- this will add a "\_vagrantci\_" directory
- enter directory:
<pre>cd \_vagrantci\_</pre>
- installation is now complete

### Contributions welcome!
Please report bugs and include logs.


